xquery version "1.0-ml";

module namespace ch="http://marklogic.com/casemanagement/controller-helper";

import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";
import module namespace const = "http://marklogic.com/casemanagement/case-constants" at "/casemanagement/models/case-constants.xqy";
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

declare namespace c="http://marklogic.com/workflow/case";

declare function ch:validate(
  $caseid as xs:string?,         (: should always be supplied - new case will supply new caseid :)
  $new-case as xs:boolean,       (: is this new? :)
  $input-data as xs:boolean,     (: is there data? :)
  $input-expected as xs:boolean  (: should there be data? :)
) as map:map {
  map:new(
    (: supplied caseid ? :)
    if (fn:empty($caseid))
    then (
      map:entry("status-code", 404),
      map:entry("response-message", "Case not found"),
      map:entry("error-detail", "caseId parameter is required")
    )
    else
      let $case-count := fn:count( clib:get-case-document-uri($caseid) )
      return
      (: ( case exists AND new-case FALSE) OR ( case does not exist AND new-case TRUE) :)
        if ( (($case-count) and (fn:not($new-case))) or ((xs:int("0") = $case-count) and ($new-case)) )
        then
        (: what to validate :)
          if (
            (($input-expected) and ($input-data))
              or fn:not($input-expected) (: and fn:not($input-data)) - ignore input data if not expected :)
          )
          then (
            map:entry("status-code", 200),
            map:entry("response-message", "OK")
          )
          else (
            map:entry("status-code", 405),
            map:entry("response-message", "Invalid input"),
            if ($new-case)
            then map:entry("error-detail", "Nothing to insert")
            else map:entry("error-detail", "Nothing to update")
          )
        else
          if ($new-case)
          then (
            map:entry("status-code", 400),
            map:entry("response-message", "Invalid ID supplied"),
            map:entry("error-detail", fn:concat("caseId ", $caseid, " exists"))
          )
          else (
            map:entry("status-code", 400),
            map:entry("response-message", "Invalid ID supplied"),
            map:entry("error-detail", fn:concat("caseId ", $caseid, " not found"))
          )
  )
};

declare function ch:make-rest-response($output as map:map, $context as map:map, $preftype as xs:string) {
  (: JUST GOOD RESPONSE ? :)
  let $status-code := map:get($output,"status-code")
  let $response-message := map:get($output,"response-message")
  return
    if (200 = $status-code)
    then (
      map:put($context, "output-types", $preftype),
      xdmp:set-response-code($status-code, $response-message),
      document {
        if ("application/xml" = $preftype) then
          map:get($output,"document")
        else if ("text/plain" = $preftype) then
          map:get($output,"text")
        else
          let $config := json:config("custom")
          let $cx := map:put($config, "text-value", "label")
          let $cx := map:put($config, "camel-case", fn:true())
          return
            json:transform-to-json(map:get($output,"document"), $config)
      }
    )
    else fn:error((), "RESTAPI-SRVEXERR", ($status-code, $response-message, map:get($output,"error-detail")))
};

(:
 : Create a new process and activate it.
 :)
declare function ch:case-create($case-template-name as xs:string, $data as element(c:case), $permissions as xs:string*, $parent as xs:string?) as xs:string {
  let $id := clib:get-new-case-id($data)
  let $uri := fn:concat($const:case-dir, $case-template-name, "/", $id, ".xml")
  let $_ := xdmp:log(fn:concat("creating case for id:", $id, ", uri:", $uri), "debug")
  let $_ := clib:create-case-document($uri, $data, $permissions)
  return $id
};
(:
declare function ch:case-create($case-template-name as xs:string,$data as element()*,$attachments as element()*,$parent as xs:string?) as xs:string {
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
  let $_ := ch:createCaseDocument($uri,$doc)
  return $id
};
:)

(:
declare private function ch:audit-create($case-id as xs:string,$status as xs:string,$eventCategory as xs:string,$description as xs:string,$detail as node()*) as element(c:audit) {
  <c:audit><c:by>{xdmp:get-current-user()}</c:by><c:when>{fn:current-dateTime()}</c:when>
    <c:category>{$eventCategory}</c:category><c:status>{$status}</c:status>
    <c:description>{$description}</c:description><c:detail>{$detail}</c:detail>
  </c:audit>
};

declare private function ch:check-update-in-sequence($case as element(c:case),$updateTag as xs:string) as xs:boolean {
  $updateTag = $case/@c:update-tag
};

declare private function ch:update-tag($case as element(c:case)) {
  if (fn:not(fn:empty($case/@c:update-tag))) then
    xdmp:node-replace($case/@c:update-tag,attribute c:update-tag {
      sem:uuid-string() || "-" || xs:string(fn:current-dateTime())
    })
  else
    xdmp:node-insert-child($case,attribute c:update-tag {
      sem:uuid-string() || "-" || xs:string(fn:current-dateTime())
    })
};

declare function ch:case-update($case-id as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {
:)
declare function ch:case-update($case-id as xs:string, $data as element(c:case), $permissions as xs:string*, $parent as xs:string?) as xs:boolean {
  clib:update-case-document($case-id, $data, $permissions)
  (:
  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  ( : TODO don't just blanket replace all data and attachments, replace one by one : )
  ( : if data or attachment nodes are blank, leave them as they are - do not replace them with nothing : )
  ( : TODO fail if already closed : )
  let $case := ch:case-get($case-id,fn:true())
  return
    if (m:check-update-in-sequence($case,$updateTag)) then
      let $_ := (
        ch:update-tag($case),
        if (fn:not(fn:empty($dataUpdates))) then
          xdmp:node-replace($case/c:data,<c:data>{$dataUpdates}</c:data>)
        else (),
        if (fn:not(fn:empty($attachmentUpdates))) then
          xdmp:node-replace($case/c:attachments,<c:attachments>{$attachmentUpdates}</c:attachments>)
        else (),
          xdmp:node-insert-child($case/c:audit-trail,
            ch:audit-create($case-id,"Open","Lifecycle","Case Updated",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    else
      return fn:false() :)
};

(:
 : Default is to not lock for update (read only)
 : Returns true is locked, or if read succeeds without a need for a lock (i.e. lock wasn't requested)
 :)
declare function ch:case-get($case-id as xs:string, $lock-for-update as xs:boolean?) as element(c:case)? {
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
declare function ch:case-close($case-id as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {

  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  ( : TODO If locked, check it is by current user, fail otherwise : )
  ( : TODO Remove lockedBy, set locked to false : )
  ( : Changes status to closed : )
  ( : if data or attachment nodes are blank, leave them as they are - do not replace them with nothing : )
  ( : TODO fail if already closed : )
  let $case := ch:case-get($case-id,fn:true())
  return
    if (m:check-update-in-sequence($case,$updateTag)) then
      let $_ := (
        ch:update-tag($case), ( : Update this so it cannot be closed twice : )
        if (fn:not(fn:empty($dataUpdates))) then
          xdmp:node-replace($case/c:data,<c:data>{$dataUpdates}</c:data>)
        else (),
        if (fn:not(fn:empty($attachmentUpdates))) then
          xdmp:node-replace($case/c:attachments,<c:attachments>{$attachmentUpdates}</c:attachments>)
        else (),
          xdmp:node-replace(m:case-get($case-id,fn:true())/c:status,<c:status>Closed</c:status>),
          xdmp:node-insert-child($case/c:audit-trail,
            ch:audit-create($case-id,"Closed","Lifecycle","Case Closed",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    return fn:false()
}; :)
