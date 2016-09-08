xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow-actions";

import module namespace wfr="http://marklogic.com/workflow-runtime" at "/app/models/workflow-runtime.xqy";
import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";

declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace wf="http://marklogic.com/workflow";
declare namespace p="http://marklogic.com/cpf/pipelines";
declare namespace error="http://marklogic.com/xdmp/error";

import module namespace wfdefs = "http://marklogic.com/workflow-definitions" at "/app/models/workflow-definitions.xqy";
import module namespace wfp = "http://marklogic.com/workflow-process" at "/app/models/workflow-process.xqy";

(:
 : This library holds complementary actions for CPF actions for BPMN2 steps.
 : E.g. a user task CPF action pauses the workflow, whereas a complementary method here uses that step information
 : and continues the workflow.
 :)

 (:
  : SECURITY NOTICE
  :
  : Functions in this library should only be executable by those with the workflow-user privilege, unless explicitly an outside API.
  :)

(: EXTERNAL CALLABLE FUNCTIONS - update-* updates the task, but does not complete it. complete-* does update and complete. :)



(:
 : Called by the REST API only.
 :)
declare function m:lock($processId as xs:string) as node()? {
  (: Check that this is a human queue task or user task :)
  let $props := m:getProperties($processId)
  return
    if ($props/wf:currentStep/wf:step-type = "userTask" and $props/wf:currentStep/wf:step-status = "ENTERED") then
      if ($props/wf:currentStep/wf:type = "user" or $props/wf:currentStep/wf:type = "queue" or $props/wf:currentStep/wf:type = "role") then
        if (fn:empty($props/wf:currentStep/wf:lock)) then
          (: lock and return success :) (: TODO check what happens if this call fails... :)
          (
            xdmp:node-insert-child($props/wf:currentStep,<wf:lock><wf:by>{xdmp:get-current-user()}</wf:by><wf:when>{xdmp:current-dateTime()}</wf:when></wf:lock>)
            ,
            wfr:audit(m:getProcessUri($processId),(),"ProcessEngine","Work item locked by '" || xdmp:get-current-user() || "'",())
          )
        else
          if ($props/wf:currentStep/wf:lock/wf:by = xdmp:get-current-user()) then
            (: Do nothing - ok :)
            ()
          else
            (: Fail :)
            "Could not lock work item. Work item is already locked by '" || xs:string($props/wf:currentStep/wf:lock/wf:by) || "'"
      else
        "Could not lock work item. userTask type '" || xs:string($props/wf:currentStep/wf:type) || "' not supported for locking."
    else
      "Could not lock work item. Step is not a userTask, or status is not 'ENTERED'. Try again."
  (: If assigned to user task, and this user, always return true even if already locked :)
  (: Check that this item is not already locked if a queue task :)
  (: Lock the work item :)
  (: Return blank if ok :)
};

(:
 : Allow unlocking of a work item. (Not the same as completion). Does not return data.
 :)
declare function m:unlock($processId as xs:string) as node()? {
let $props := m:getProperties($processId)
return
  if ($props/wf:currentStep/wf:step-type = "userTask" and $props/wf:currentStep/wf:step-status = "ENTERED") then
    if ($props/wf:currentStep/wf:type = "user" or $props/wf:currentStep/wf:type = "queue" or $props/wf:currentStep/wf:type = "role") then
      if (fn:empty($props/wf:currentStep/wf:lock)) then
        () (: Just succeed, rather than error - means we are alreay unlocked! :)
      else
        if ($props/wf:currentStep/wf:lock/wf:by = xdmp:get-current-user()) then
          (: Unlock :)
          (
            xdmp:node-delete($props/wf:currentStep/wf:lock)
            ,
            wfr:audit(m:getProcessUri($processId),(),"ProcessEngine","Work item unlocked by '" || xdmp:get-current-user() || "'",())
          )
        else
          (: Fail :)
          "Could not unlock work item. Work item is locked by a different user: '" || xs:string($props/wf:currentStep/wf:lock/wf:by) || "'"
    else
      "Could not unlock work item. userTask type '" || xs:string($props/wf:currentStep/wf:type) || "' not supported for locking."
  else
    "Could not unlock work item. Step is not a userTask, or status is not 'ENTERED'. Try again."
};


declare function m:update-userTask($processId as xs:string,$data as node()*,$attachments as node()*) as node()? {
  let $_secure := xdmp:security-assert($wfdefs:privUser, "execute")

  let $_ := xdmp:log("In wfa:update-userTask")
  return
    update-generic($processId,$data,$attachments)
};

(:
 : Complete a user task, moving it on to the next step. (Just marks as complete)
 :)
declare function m:complete-userTask($processId as xs:string,$data as node()*,$attachments as node()*) as node()? {
  let $_secure := xdmp:security-assert($wfdefs:privUser, "execute")

  let $_ := xdmp:log("In wfa:complete-userTask")
  let $unlock :=
    if (fn:not(fn:empty(wfu:getProperties($processId)/wf:currentStep/wf:lock))) then
      wfu:unlock($processId) (: We call this to ensure this user has the current lock, even though wf:currentStep will be deleted :)
    else
      ()
  (: Find process document :)
  (: Get next step ID :)
  (: TODO check required attachments and properties here (Should be done in the UI) :)
  let $update := 
    if (fn:empty($unlock)) then
      update-userTask($processId,$data,$attachments)
    else
      $unlock (: report issue :)
  (: TODO lookup functionality from document patch in REST API to see if we can replicate that method here :)
  return
    if (fn:empty($update)) then complete-generic($processId) else $update
};



(: INTERNAL METHODS :)
declare private function m:update-generic($processId as xs:string,$data as node()*,$attachments as node()*) as node()? {
  let $_ := xdmp:log("In wfa:update-generic")

	let $previous-data := fn:doc(wfp:getProcessUri($processId))/wf:process/wf:data
	let $previous-attach := fn:doc(wfp:getProcessUri($processId))/wf:process/wf:attachments

  return (
    (: This method needs an amp to workflow-internal in order to modify the process doc :)
    (: TODO SECURITY add sanity checks to ensure THIS user is allowed to do this to THIS instance :)
      xdmp:node-replace(fn:doc(wfp:getProcessUri($processId))/wf:process/wf:data,
        (: Keep previous data if not newly sent and add new elements :)
        element wf:data {
          ($previous-data/* except $data/(let $qname := fn:node-name(.) return $previous-data/*[fn:node-name(.) eq $qname])),
          $data
        }
      ),
      xdmp:node-replace(fn:doc(wfp:getProcessUri($processId))/wf:process/wf:attachments,
      	(: Keep previous data if not newly sent and add new elements :)
        element wf:attachments {
          ($previous-attach/* except $previous-attach/*[@name eq $attachments/@name]),
          $attachments
        }
      )
  )
};

(:
 : Marks as complete ONLY. Does not call wfu:complete
 :)
declare private function m:complete-generic($processId as xs:string) as empty-sequence() {
  let $_ := xdmp:log("In wfa:complete-generic: processId: "||$processId)
  let $props := wfp:getProperties($processId) (: WFU MODULE :)
  let $_ := xdmp:log($props)
  (:
  let $next := $props/prop:properties/wf:currentStep/wf:state/text()  (: WHERE SHOULD THIS BE FROM INSTEAD ? :)
  let $_ := xdmp:log($next)
  :)
  let $transition := $props/cpf:state/text()
  let $_ := xdmp:log("wfa:complete-generic: transition: " || $transition)
(:)  let $startTime := xs:dateTime($props/prop:properties/wf:currentStep/wf:startTime):)
  (:let $_ := xdmp:log($startTime):)
  (:let $update := xdmp:document-remove-properties(wfu:getProcessUri($processId),xs:QName("wf:currentStep")) :)
  (:let $update := xdmp:node-delete($props/wf:currentStep)
  let $_ := xdmp:log($update) :)
  return
    (: wfu:completeById($processId,$transition,xs:anyURI($next),$startTime) :)
    (: THIS FUNCTION MUST BE AMPED TO INCLUDE THE WORKFLOW-RUNTIME ROLE :)
    wfr:finallyComplete($processId,$transition)
};
