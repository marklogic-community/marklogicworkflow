xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow-instantiation";

import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";

declare namespace wf="http://marklogic.com/workflow";

import module namespace wfdefs = "http://marklogic.com/workflow-definitions" at "/app/models/workflow-definitions.xqy";

(: SECURITY NOTICE
 : This file should be executed by a user with the workflow-instantiator privilege only.
 : It can also be called via an amp from the runtime's subprocess-create function
 :)

(:
 : Create a new process and activate it.
 :)
declare function m:create($pipelineName as xs:string,$data as element()*,$attachments as element()*,$parent as xs:string?,$forkid as xs:string?,$branchid as xs:string?) as xs:string {
  let $_secure := xdmp:security-assert($wfdefs:privInstantiator, "execute") (: TODO ALLOW RUNTIME USER TOO :)

  (: Note in order for this to work, we must AMP this function to workflow-internal (runtime) so initial actions run with correct privileges :)

  (: TODO SECURITY execute this as an invoke-function, and execute as workflow-internal - ensures tasks run as workflow-internal throughout :)
  let $id := sem:uuid-string() || "-" || xs:string(fn:current-dateTime())
  let $uri := "/workflow/processes/"||$pipelineName||"/"||$id || ".xml"
  let $doc := <wf:process id="{$id}">
    <wf:data>{$data}</wf:data>
    <wf:attachments>{$attachments}</wf:attachments>
    <wf:audit-trail></wf:audit-trail>
    <wf:metrics></wf:metrics>
    <wf:process-definition-name>{$pipelineName}</wf:process-definition-name>
    {if (fn:not(fn:empty($parent))) then <wf:parent>{$parent}</wf:parent> else ()}
    {if (fn:not(fn:empty($forkid))) then <wf:forkid>{$forkid}</wf:forkid> else ()}
    {if (fn:not(fn:empty($branchid))) then <wf:branchid>{$branchid}</wf:branchid> else ()}
  </wf:process>
  let $_ := m:createProcessDocument($uri,$doc)
  (: SECURITY NOTE the above function requires the xdmp:login privilege amp - which MUST be CAREFULLY controlled :)
  return $id
};

declare private function m:createProcessDocument($uri as xs:string,$doc as element()) {
  let $_secure := xdmp:security-assert($wfdefs:privInstantiator, "execute")
  (: Belt and braces :)
  return xdmp:invoke-function(
    function() {
      xdmp:document-insert($uri,
        $doc,
        (
          xdmp:default-permissions(),
          xdmp:permission("workflow-internal",("read","update")),
          (:xdmp:permission("workflow-status",("read")), :) (: WARNING DO NOT UNCOMMENT - reading should be wrapped and amped to prevent data leakage :)
          xdmp:permission("workflow-administrator",("read","update")),
          xdmp:permission("workflow-user",("read")) (: TODO replace this with the EXACT user, dynamically, as required :)
        ),
        (
          xdmp:default-collections(),
          "http://marklogic.com/workflow/processes"
        )
      )

    },
    <options xmlns="xdmp:eval">
      <database>{xdmp:database()}</database>
      <transaction-mode>update-auto-commit</transaction-mode>
      <isolation>different-transaction</isolation>
      <user-id>{xdmp:user("workflow-internal")}</user-id>
    </options>
  )
};
