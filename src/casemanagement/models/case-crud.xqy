xquery version "1.0-ml";

module namespace m="http://marklogic.com/casemanagement/case-crud";

import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
declare namespace c="http://marklogic.com/workflow/case";

(:
 : Create a new process and activate it.
 :)
declare function m:case-create($case-template-name as xs:string, $data as element(c:case), $permissions as xs:string*, $parent as xs:string?) as xs:string {
  let $id := sem:uuid-string() || "-" || xs:string(fn:current-dateTime())
  let $uri := fn:concat("/casemanagement/cases/", $case-template-name, "/", $id, ".xml")
  let $_ := xdmp:log(fn:concat("creating case for id:", $id, ", uri:", $uri), "debug")
  let $_ := clib:create-case-document($uri, $data, $permissions)
  return $id
};
(:
declare function m:case-create($case-template-name as xs:string,$data as element()*,$attachments as element()*,$parent as xs:string?) as xs:string {
  let $id := sem:uuid-string() || "-" || xs:string(fn:current-dateTime())
  let $uri := "/casemanagement/cases/"||$case-template-name||"/"||$id || ".xml"
  let $doc := <c:case id="{$id}">
    <c:data>{$data}</c:data>
    <c:attachments>{$attachments}</c:attachments>
    <c:audit-trail>{m:audit-create($id,"Created","Lifecycle","Case Created",($data,$attachments))}</c:audit-trail>
    <c:metrics></c:metrics>

    <c:status>Open</c:status>
    <c:locked>{fn:false()}</c:locked>

    <c:case-template-name>{$case-template-name}</c:case-template-name>
    {if (fn:not(fn:empty($parent))) then <c:parent>{$parent}</c:parent> else ()}
  </c:case>
  let $_ := m:createCaseDocument($uri,$doc)
  return $id
};
:)

(:
declare private function m:audit-create($case-id as xs:string,$status as xs:string,$eventCategory as xs:string,$description as xs:string,$detail as node()*) as element(c:audit) {
  <c:audit><c:by>{xdmp:get-current-user()}</c:by><c:when>{fn:current-dateTime()}</c:when>
    <c:category>{$eventCategory}</c:category><c:status>{$status}</c:status>
    <c:description>{$description}</c:description><c:detail>{$detail}</c:detail>
  </c:audit>
};

declare private function m:check-update-in-sequence($case as element(c:case),$updateTag as xs:string) as xs:boolean {
  $updateTag = $case/@c:update-tag
};

declare private function m:update-tag($case as element(c:case)) {
  if (fn:not(fn:empty($case/@c:update-tag))) then
    xdmp:node-replace($case/@c:update-tag,attribute c:update-tag {
      sem:uuid-string() || "-" || xs:string(fn:current-dateTime())
    })
  else
    xdmp:node-insert-child($case,attribute c:update-tag {
      sem:uuid-string() || "-" || xs:string(fn:current-dateTime())
    })
};

declare function m:case-update($case-id as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {
:)
declare function m:case-update($case-id as xs:string, $data as element(c:case), $permissions as xs:string*, $parent as xs:string?) as xs:boolean {
  clib:update-case-document($case-id, $data, $permissions)
  (:
  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  ( : TODO don't just blanket replace all data and attachments, replace one by one : )
  ( : if data or attachment nodes are blank, leave them as they are - do not replace them with nothing : )
  ( : TODO fail if already closed : )
  let $case := m:case-get($case-id,fn:true())
  return
    if (m:check-update-in-sequence($case,$updateTag)) then
      let $_ := (
        m:update-tag($case),
        if (fn:not(fn:empty($dataUpdates))) then
          xdmp:node-replace($case/c:data,<c:data>{$dataUpdates}</c:data>)
        else (),
        if (fn:not(fn:empty($attachmentUpdates))) then
          xdmp:node-replace($case/c:attachments,<c:attachments>{$attachmentUpdates}</c:attachments>)
        else (),
          xdmp:node-insert-child($case/c:audit-trail,
            m:audit-create($case-id,"Open","Lifecycle","Case Updated",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    else
      return fn:false() :)
};

(:
 : Default is to not lock for update (read only)
 : Returns true is locked, or if read succeeds without a need for a lock (i.e. lock wasn't requested)
 :)
declare function m:case-get($case-id as xs:string, $lock-for-update as xs:boolean?) as element(c:case)? {
  (:  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute") :)
  let $collection := "http://marklogic.com/casemanagement/cases"

  let $case := fn:collection($collection)/c:case[@id = $case-id][1] (: sanity check :)
  return
    if ($case)
    then $case
    else
      let $dir := "/casemanagement/cases/"
      let $uri := clib:get-case-document-uri($case-id)
      return cts:search(
        fn:collection($collection),
        (: cts:and-query(( :)
        (:  cts:directory-query($dir, "infinity"), :)
        cts:document-query($uri)
        (: )) :)
      )/c:case[1]
  (: TODO add audit entry item :)
  (: TODO add locked audit entry item too :)
};

(:
 : Succeeds and returns true if case successfully updated and closed
 : )
declare function m:case-close($case-id as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {

  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  ( : TODO If locked, check it is by current user, fail otherwise : )
  ( : TODO Remove lockedBy, set locked to false : )
  ( : Changes status to closed : )
  ( : if data or attachment nodes are blank, leave them as they are - do not replace them with nothing : )
  ( : TODO fail if already closed : )
  let $case := m:case-get($case-id,fn:true())
  return
    if (m:check-update-in-sequence($case,$updateTag)) then
      let $_ := (
        m:update-tag($case), ( : Update this so it cannot be closed twice : )
        if (fn:not(fn:empty($dataUpdates))) then
          xdmp:node-replace($case/c:data,<c:data>{$dataUpdates}</c:data>)
        else (),
        if (fn:not(fn:empty($attachmentUpdates))) then
          xdmp:node-replace($case/c:attachments,<c:attachments>{$attachmentUpdates}</c:attachments>)
        else (),
          xdmp:node-replace(m:case-get($case-id,fn:true())/c:status,<c:status>Closed</c:status>),
          xdmp:node-insert-child($case/c:audit-trail,
            m:audit-create($case-id,"Closed","Lifecycle","Case Closed",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    return fn:false()
}; :)
