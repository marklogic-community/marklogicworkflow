xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow/case-crud";

declare namespace c="http://marklogic.com/workflow/case";

import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";

import module namespace cdefs = "http://marklogic.com/case-definitions" at "/app/models/case-definitions.xqy";

(: SECURITY NOTICE
 : This file should be executed by a user with the case-instantiator privilege only.
 : It can also be called via an amp from the runtime's subprocess-create function
 :)

(:
 : Create a new process and activate it.
 :)
declare function m:case-create($caseTemplateName as xs:string,$data as element()*,$attachments as element()*,$parent as xs:string?) as xs:string {
  let $_secure := xdmp:security-assert($cdefs:privCaseInstantiator, "execute") (: TODO ALLOW RUNTIME USER TOO :)

  (: Note in order for this to work, we must AMP this function to case-internal (runtime) so initial actions run with correct privileges :)

  (: TODO SECURITY execute this as an invoke-function, and execute as case-internal - ensures tasks run as case-internal throughout :)
  (: TODO add created by audit trail item :)
  let $id := sem:uuid-string() || "-" || xs:string(fn:current-dateTime())
  let $uri := "/workflow/cases/"||$caseTemplateName||"/"||$id || ".xml"
  let $doc := <c:case id="{$id}">
    <c:data>{$data}</c:data>
    <c:attachments>{$attachments}</c:attachments>
    <c:audit-trail>{m:audit-create($id,"Created","Lifecycle","Case Created",($data,$attachments))}</c:audit-trail>
    <c:metrics></c:metrics>
    
    <c:status>Open</c:status>
    <c:locked>{fn:false()}</c:locked>

    <c:case-template-name>{$caseTemplateName}</c:case-template-name>
    {if (fn:not(fn:empty($parent))) then <c:parent>{$parent}</c:parent> else ()}
  </c:case>
  let $_ := m:createCaseDocument($uri,$doc)
  (: SECURITY NOTE the above function requires the xdmp:login privilege amp - which MUST be CAREFULLY controlled :)
  return $id
};

declare private function m:createCaseDocument($uri as xs:string,$doc as element()) as xs:boolean {
  let $_ := xdmp:document-insert($uri,$doc,
        (
          xdmp:default-permissions(),
          xdmp:permission("case-internal",("read","update")),
          (:xdmp:permission("workflow-status",("read")), :) (: WARNING DO NOT UNCOMMENT - reading should be wrapped and amped to prevent data leakage :)
          xdmp:permission("case-administrator",("read","update")),
          xdmp:permission("case-user",("read")) (: TODO replace this with the EXACT user, dynamically, as required :)
        ),
        (
          xdmp:default-collections(),
          "http://marklogic.com/workflow/cases"
        )
      
  )
  return fn:true()
};

declare private function m:audit-create($caseId as xs:string,$status as xs:string,$eventCategory as xs:string,$description as xs:string,$detail as node()*) as element(c:audit) {
  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute") (: Requires amp from same module :)

  return <c:audit><c:by>{xdmp:get-current-user()}</c:by><c:when>{fn:current-dateTime()}</c:when>
    <c:category>{$eventCategory}</c:category><c:status>{$status}</c:status>
    <c:description>{$description}</c:description><c:detail>{$detail}</c:detail></c:audit>
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

declare function m:case-update($caseId as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {

  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  (: TODO don't just blanket replace all data and attachments, replace one by one :)
  (: if data or attachment nodes are blank, leave them as they are - do not replace them with nothing :)
  (: TODO fail if already closed :)
  let $case := m:case-get($caseId,fn:true())
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
            m:audit-create($caseId,"Open","Lifecycle","Case Updated",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    else
      return fn:false()
};

(:
 : Default is to not lock for update (read only)
 : Returns true is locked, or if read succeeds without a need for a lock (i.e. lock wasn't requested)
 :)
declare function m:case-get($caseId as xs:string,$lockForUpdate as xs:boolean?) as element(c:case)? {
  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  return fn:collection("http://marklogic.com/workflow/cases")/c:case[@id = $caseId][1] (: sanity check :)
  (: TODO add audit entry item :)
  (: TODO add locked audit entry item too :)
};

(:
 : Succeeds and returns true if case successfully updated and closed
 :)
declare function m:case-close($caseId as xs:string,$updateTag as xs:string,$dataUpdates as element()*,
  $attachmentUpdates as element()*) as xs:boolean {

  let $_secure := xdmp:security-assert($cdefs:privCaseUser, "execute")

  (: TODO If locked, check it is by current user, fail otherwise :)
  (: TODO Remove lockedBy, set locked to false :)
  (: Changes status to closed :)
  (: if data or attachment nodes are blank, leave them as they are - do not replace them with nothing :)
  (: TODO fail if already closed :)
  let $case := m:case-get($caseId,fn:true())
  return
    if (m:check-update-in-sequence($case,$updateTag)) then
      let $_ := (
        m:update-tag($case), (: Update this so it cannot be closed twice :)
        if (fn:not(fn:empty($dataUpdates))) then
          xdmp:node-replace($case/c:data,<c:data>{$dataUpdates}</c:data>)
        else (),
        if (fn:not(fn:empty($attachmentUpdates))) then
          xdmp:node-replace($case/c:attachments,<c:attachments>{$attachmentUpdates}</c:attachments>)
        else (),
          xdmp:node-replace(m:case-get($caseId,fn:true())/c:status,<c:status>Closed</c:status>),
          xdmp:node-insert-child($case/c:audit-trail,
            m:audit-create($caseId,"Closed","Lifecycle","Case Closed",($dataUpdates,$attachmentUpdates)) )
      )
      return fn:true()
    return fn:false()
};
