xquery version "1.0-ml";

module namespace clib="http://marklogic.com/casemanagement/case-lib";

import module namespace const = "http://marklogic.com/casemanagement/case-constants" at "/casemanagement/models/case-constants.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";

declare namespace c="http://marklogic.com/workflow/case";

declare function clib:get-new-id($doc as element()?){
  if (fn:exists($doc/@id))
  then xs:string($doc/@id)
  else wfu:new-workflow-id()
};

declare function clib:get-case-document-uri($case-id as xs:string){
  cts:uri-match(fn:concat($const:case-dir, '*/', $case-id, ".xml"))
};

declare function clib:get-case-document($case-id as xs:string){
  let $uri := clib:get-case-document-uri($case-id)
  return doc($uri)
};

declare function clib:get-case-document-from-activity($activity-id as xs:string){
  cts:search(
    fn:collection($const:case-collection),
    cts:element-attribute-range-query(
      xs:QName("c:activity"), xs:QName("id"), "=", $activity-id) )
};

declare function clib:get-activity-document($activity-id as xs:string){
  let $case := clib:get-case-document-from-activity($activity-id)
  return $case/c:case/c:phases/c:phase/c:activities/c:activity[@id=$activity-id]
};

declare function clib:create-case-document($uri as xs:string, $doc as element(), $permissions-string as xs:string*) as xs:boolean {
  let $permissions := clib:decode-permissions($permissions-string)
  let $_ := xdmp:document-insert($uri, $doc,
        $permissions,
        (
          xdmp:default-collections(),
          $const:case-collection
        )
  )
  return fn:true()
};

declare function clib:decode-permissions ($permissions-string as xs:string*) as element(sec:permission)* {
  (: TODO: implement properly... :)
  (
    xdmp:default-permissions(),
    $const:case-permissions,
    (: xdmp:permission("workflow-status",("read")), :) (: WARNING DO NOT UNCOMMENT - reading should be wrapped and amped to prevent data leakage :)
    xdmp:permission("case-user",("read")) (: TODO replace this with the EXACT user, dynamically, as required :)
  )
};

declare function clib:update-case-document($case-id as xs:string, $doc as element(), $permissions-string as xs:string*) as xs:boolean {
  (: At the moment we're doing a straight swap... :)
  let $uri := clib:get-case-document-uri($case-id)
  return clib:create-case-document($uri, $doc, $permissions-string)
};

(:
declare private function clib:audit-create($case-id as xs:string,$status as xs:string,$eventCategory as xs:string,$description as xs:string,$detail as node()*) as element(c:audit) {
  <c:audit><c:by>{xdmp:get-current-user()}</c:by><c:when>{fn:current-dateTime()}</c:when>
    <c:category>{$eventCategory}</c:category><c:status>{$status}</c:status>
    <c:description>{$description}</c:description><c:detail>{$detail}</c:detail>
  </c:audit>
};

declare private function clib:check-update-in-sequence($case as element(c:case),$updateTag as xs:string) as xs:boolean {
  $updateTag = $case/@c:update-tag
};

declare private function clib:update-tag($case as element(c:case)) {
  if (fn:not(fn:empty($case/@c:update-tag))) then
    xdmp:node-replace($case/@c:update-tag,attribute c:update-tag {
      seclib:uuid-string() || "-" || xs:string(fn:current-dateTime())
    })
  else
    xdmp:node-insert-child($case,attribute c:update-tag {
      seclib:uuid-string() || "-" || xs:string(fn:current-dateTime())
    })
};

declare function clib:case-update($case-id as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {

  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  ( : TODO don't just blanket replace all data and attachments, replace one by one : )
  ( : if data or attachment nodes are blank, leave them as they are - do not replace them with nothing : )
  ( : TODO fail if already closed : )
  let $case := clib:case-get($case-id,fn:true())
  return
    if (clib:check-update-in-sequence($case,$updateTag)) then
      let $_ := (
        clib:update-tag($case),
        if (fn:not(fn:empty($dataUpdates))) then
          xdmp:node-replace($case/c:data,<c:data>{$dataUpdates}</c:data>)
        else (),
        if (fn:not(fn:empty($attachmentUpdates))) then
          xdmp:node-replace($case/c:attachments,<c:attachments>{$attachmentUpdates}</c:attachments>)
        else (),
          xdmp:node-insert-child($case/c:audit-trail,
            clib:audit-create($case-id,"Open","Lifecycle","Case Updated",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    else
      return fn:false()
};
:)

(:
 : Succeeds and returns true if case successfully updated and closed
 : )
declare function clib:case-close($case-id as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {

  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  ( : TODO If locked, check it is by current user, fail otherwise : )
  ( : TODO Remove lockedBy, set locked to false : )
  ( : Changes status to closed : )
  ( : if data or attachment nodes are blank, leave them as they are - do not replace them with nothing : )
  ( : TODO fail if already closed : )
  let $case := clib:case-get($case-id,fn:true())
  return
    if (clib:check-update-in-sequence($case,$updateTag)) then
      let $_ := (
        clib:update-tag($case), ( : Update this so it cannot be closed twice : )
        if (fn:not(fn:empty($dataUpdates))) then
          xdmp:node-replace($case/c:data,<c:data>{$dataUpdates}</c:data>)
        else (),
        if (fn:not(fn:empty($attachmentUpdates))) then
          xdmp:node-replace($case/c:attachments,<c:attachments>{$attachmentUpdates}</c:attachments>)
        else (),
          xdmp:node-replace(clib:case-get($case-id,fn:true())/c:status,<c:status>Closed</c:status>),
          xdmp:node-insert-child($case/c:audit-trail,
            clib:audit-create($case-id,"Closed","Lifecycle","Case Closed",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    return fn:false()
}; :)
