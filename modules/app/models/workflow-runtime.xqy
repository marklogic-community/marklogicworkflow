xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow-runtime";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";


declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace wf="http://marklogic.com/workflow";
declare namespace p="http://marklogic.com/cpf/pipelines";
declare namespace error="http://marklogic.com/xdmp/error";


import module namespace wfdefs = "http://marklogic.com/workflow-definitions" at "/app/models/workflow-definitions.xqy";
import module namespace wfin = "http://marklogic.com/workflow-instantiation" at "/app/models/workflow-instantiation.xqy";
import module namespace wfp = "http://marklogic.com/workflow-process" at "/app/models/workflow-process.xqy";

(:
 : TODO SECURITY NOTICE
 :)



(:
 : Convenience function to take a few parameters and set up the above call to m:create (removes this logic from multiple functions)
 :)
declare private function m:createSubProcess($parentProcessUri as xs:string,$forkid as xs:string,$subProcessStatus as element(wf:branch-status)) as xs:string {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  let $parent := fn:doc($parentProcessUri)/wf:process
  let $pipelineName := xs:string($parent/wf:process-definition-name) || "/" || xs:string($subProcessStatus/wf:branch)
  (: TODO AMP TO CALL CREATE :)
  return wfin:create($pipelineName,<data>{$parent/wf:data}</data>/*,<data>{$parent/wf:attachments}</data>/*,$parentProcessUri,$forkid,xs:string($subProcessStatus/wf:branch))
};



(:
 : Can be called from out of sequence (non CPF) modules - forces a CPF re-evaluation, then complete, in conjunction with the restart.xqy action
 :)
declare function m:finallyComplete($processId as xs:string,$transition as xs:string) as empty-sequence() {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  let $processUri := wfp:getProcessUri($processId)
  let $props := xdmp:document-properties($processUri)/prop:properties
  let $_ := m:audit($processUri,$transition,"ProcessEngine","Marking as Complete",())
  return
    (
    xdmp:node-replace($props/wf:currentStep/wf:step-status,<wf:step-status>COMPLETE</wf:step-status>)
    (: NOTE SECURITY The above requires an amp so that CPF runs as workflow-internal when cpf-property-update occurs :)
    (:,
    xdmp:node-replace($props/cpf:status,<cpf:processing-status>active</cpf:processing-status>)
    :)
    (:
    ),
    xdmp:node-replace($props/cpf:status,<cpf:state>{$props/wf:currentStep/wf:state/text()}</cpf:state>)
    :)
    (:
    ,
    (: god awful hack to test CPF updated status change handling :)
    xdmp:node-insert-after(fn:doc($processUri)/wf:process/wf:data,<tag>You're it</tag>)
    :)
    )
};

(:
 : This module performs process data document update functions via a high level abstraction.
 : WARNING SHOULD BE CALLED FROM WITHIN A CPF ACTION MODULE ONLY.
 :)

declare function m:complete($processUri as xs:string,$transition as node(),$stateOverride as xs:anyURI?,$startTime as xs:dateTime) as empty-sequence() {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  (: Fetch process model doc properties and Update completion time :)
  (:let $_ := xdmp:document-set-property($processUri,<wf:status>COMPLETE</wf:status>) :)
  let $_ := xdmp:log("In wfu:complete: " || $processUri || ", stateOverride: " || $stateOverride)
  let $_ := xdmp:log("  startTime")
  let $_ := xdmp:log($startTime)
  let $_ := xdmp:log("  transition")
  let $_ := xdmp:log($transition)


  (: check if we're in a subprocess, AND we are completing the last step (_end), and update just our RV status on parent :)
  (: Performance improvement - only update parent if status has changed :)
  let $audit-detail :=
    if (fn:substring($transition/name,fn:string-length($transition/name) - 3) = "_end") then
      m:updateStatusInParent($processUri)
    else ()

  (: clean up BPMN2 activity step properties :)
  let $cs := xdmp:document-properties($processUri)/prop:properties/wf:currentStep
  let $_ := if (fn:not(fn:empty($cs))) then xdmp:node-delete($cs) else ()

  let $_ := m:metric($processUri,$transition/p:state/text(),$startTime,fn:current-dateTime(),fn:true())
  (: Add audit event :)
  let $_ := m:audit($processUri,$transition/p:state/text(),"ProcessEngine","Completed step",$audit-detail)
  return
    (: Call CPF Success with next state :)
    (: ( :)
      cpf:success($processUri,$transition,$stateOverride)
    (: ,cpf:document-set-processing-status($processUri,"updated")) :)
};

(:
 : WARNING SHOULD BE CALLED FROM WITHIN A CPF ACTION MODULE ONLY.
 :)
declare function m:completeById($processId as xs:string,$transition as xs:string,$stateOverride as xs:anyURI?,$startTime as xs:dateTime) as empty-sequence() {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  let $_ := xdmp:log("Calling wfu:completeById: id: " || $processId)
  return m:complete(wfp:getProcessUri($processId),m:transitionByPath($transition),$stateOverride,$startTime)
};



declare private function m:transitionByPath($path as xs:string) as element(p:state-transition)? {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  return xdmp:eval('xquery version "1.0-ml";declare namespace m="http://marklogic.com/workflow"; import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";declare variable $m:path as xs:string external;xdmp:unpath($m:path)',
    (xs:QName("wf:path"),$path),
    <options xmlns="xdmp:eval">
      <database>{xdmp:triggers-database()}</database>
      <isolation>different-transaction</isolation>
    </options>
  )
    (:  :)
};

(:
 : Used to mark a state as in progress - i.e. the automated task is complete, but we are awaiting on an external
 : action before moving the state to the next state. E.g. human task or awaiting an external document or message.
 :)
declare function m:inProgress($processId as xs:string,$transition as xs:string) as empty-sequence() {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  let $processUri := wfp:getProcessUri($processId)
  let $_ := m:audit($processUri,$transition,"ProcessEngine","In Progress",())
  return
    xdmp:node-replace(xdmp:document-properties($processUri)/prop:properties/wf:currentStep/wf:step-status,<wf:step-status>IN PROGRESS</wf:step-status>)
};


declare function m:failure($processUri as xs:string,$transition as node(),$failureReason as element(error:error)?,$detail as node()*) as empty-sequence() {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  return (m:audit($processUri,$transition/p:state/text(),"Exception",$failureReason/error:code/text(),($failureReason,$detail))
    ,
    cpf:failure($processUri,$transition,$failureReason,())
  )
};

declare private function m:audit($processUri as xs:string,$state as xs:string,$eventCategory as xs:string,$description as xs:string,$detail as node()*) as empty-sequence() {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  (: Perform append operation on process document's audit element :)
  return xdmp:node-insert-child(fn:doc($processUri)/wf:process/wf:audit-trail,
    m:audit-create($processUri,$state,$eventCategory,$description,$detail)
  )
};

declare private function m:audit-create($processUri as xs:string,$state as xs:string,$eventCategory as xs:string,$description as xs:string,$detail as node()*) as element(wf:audit) {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  return <wf:audit><wf:by>{xdmp:get-current-user()}</wf:by><wf:when>{fn:current-dateTime()}</wf:when><wf:category>{$eventCategory}</wf:category><wf:state>{$state}</wf:state><wf:description>{$description}</wf:description><wf:detail>{$detail}</wf:detail></wf:audit>
};

declare private function m:metric($processUri as xs:string,$state as xs:string,$start as xs:dateTime,$completion as xs:dateTime,$success as xs:boolean) as empty-sequence() {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  (: Append metric event to internal metrics element :)
  return xdmp:node-insert-child(fn:doc($processUri)/wf:process/wf:metrics,
    <wf:metric><wf:state>{$state}</wf:state><wf:start>{$start}</wf:start><wf:finish>{$completion}</wf:finish>
    <wf:duration>{$completion - $start}</wf:duration>
    <wf:success>{$success}</wf:success></wf:metric>
  )
};











(: STEP SPECIFIC INFO :)




(: BRANCHING, LOOPING, FORKING, AND RENDEZVOUS FUNCTIONS :)
(:
 : Note that the branchid holds a unique ID for this branch INSTANCE not the branch name. Branch name is derived
 : from the pipeline element. Status generally initialised to INPROGRESS. Could become COMPLETE or FAILED or ABANDONED
 :)
declare private function m:branch-status($branchid as xs:string, $pipeline as xs:string,$status as xs:string?) as element(wf:branch) {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  return <wf:branch-status>
    <wf:branch>{$branchid}</wf:branch>
    <wf:pipeline>{$pipeline}</wf:pipeline>
    <wf:status>{($status,"INPROGRESS")[1]}</wf:status>
  </wf:branch-status>
};

(:
 : Possible for multiple rendezvous methods to be needed. What this is set as will depend upon the cpf:options
 : configuration passed via m:fork and the fork action.
 : Example: All (Wait for all to be complete),
 :          AllTolerant (wait for all to complete, but consider abandoned and failed as complete)
 :          One (The first one causes us to continue - although status updates will continue to be accepted),
 :          None (fire and forget)
 :
 : Contention in status updates avoided for processes that repeatedly fork by using the forkid which is unique per fork.
 :)
declare private function m:branches($forkid as xs:string,$branches as element(wf:branch-status)*,$rvmethod as xs:string) as element(wf:branches) {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  return <wf:branches>
    <wf:fork>{$forkid}</wf:fork>
    <wf:rendezvous-method>{$rvmethod}</wf:rendezvous-method>
    <wf:status>INPROGRESS</wf:status>
    {$branches}
  </wf:branches>
};

declare function m:fork($processUri as xs:string,$branch-defs as element(wf:branch-definitions)) as empty-sequence() {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  (: Create document instance for each branch (under its current process name's version folder) :)
  (: map over parent URI and (optional) loop count :)
  let $forkid := xs:string(fn:current-dateTime()) || sem:uuid-string()
  let $branches :=
    m:branches($forkid,(
      let $resultMap := map:map()
      let $_ := map:put($resultMap,"atLeastOneBranch",fn:false())
      let $mainBranches :=
        for $bd in $branch-defs/wf:branch-definition
        return
          (: if inclusiveGateway then check fork condition on EACH branch, and only create sub process for true branches :)
          let $doBranch :=
            if ($branch-defs/wf:forkMethod = "CONDITIONAL") then
              if ($bd/wf:default = "true") then
                fn:false()
              else
                let $ns := (<wf:namespace short="wf" long="http://marklogic.com/workflow" />)
                return
                  if (fn:true() = m:evaluate($processUri,$ns,$bd/wf:condition/text())) then
                    (fn:true(),map:put($resultMap,"atLeastOneBranch",fn:true()) )
                  else
                    fn:false()
            else
              fn:true() (: always true if not conditional :)
          return
            if ($doBranch) then
              let $bs := m:branch-status(xs:string($bd/wf:branch), xs:string($bd/wf:pipeline), () )
              let $doc := m:createSubProcess($processUri,$forkid,$bs) (: THIS IS WHAT CREATES THE FORKED SUB PROCESSES :) (: WFU MODULE :)
              return $bs
            else
              ()
      let $defaultBranch :=
        if ($branch-defs/wf:forkMethod = "CONDITIONAL" and fn:false() = map:get($resultMap,"atLeastOneBranch")) then
          (: process default branch now - treat as parallel for simplicity, even though its only ever one route :)
          (: This is for inclusive gateways only :)
          for $bd in $branch-defs/wf:branch-definition[./wf:default = "true"][1]
          return
            let $bs := m:branch-status(xs:string($bd/wf:branch), xs:string($bd/wf:pipeline), () )
            let $doc := m:createSubProcess($processUri,$forkid,$bs) (: THIS IS WHAT CREATES THE FORKED SUB PROCESSES :) (: WFU MODULE :)
            return $bs

        else ()
      return ($mainBranches,$defaultBranch) (: TODO if both of these are empty, throw workflow exception, as per formal spec :)
      ),xs:string($branch-defs/wf:rendezvous-method)
    )

  (: Update parent process' properties to include passed in $branches settings, and parent status to INPROGRESS :)
  let $parent-update-status := xdmp:node-insert-child(xdmp:document-properties($processUri)/prop:properties,
    <wf:currentStep>
      <wf:startTime>{fn:current-dateTime()}</wf:startTime>
      <wf:step-type>fork</wf:step-type>
      <wf:step-status>INPROGRESS</wf:step-status>
    </wf:currentStep>
  )
  let $parent-update-branches := xdmp:document-set-property($processUri,$branches)

  return ()
};

(:
 : Called by child process' complete function
 :)
declare private function m:updateStatusInParent($childProcessUri as xs:string) as element()* {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  (: Check if parent URI property exists :)
  let $parentProcessUri := xs:string(fn:doc($childProcessUri)/wf:process/wf:parent)
  let $childStatus := xs:string(xdmp:document-properties($childProcessUri)/prop:properties/wf:status)
  let $forkid := xs:string(fn:doc($childProcessUri)/wf:process/wf:forkid)
  let $branchid := xs:string(fn:doc($childProcessUri)/wf:process/wf:branchid)
  return
    if (fn:not(fn:empty($parentProcessUri))) then
      let $update := xdmp:node-replace(
        xdmp:document-properties($parentProcessUri)/prop:properties/wf:branches[./wf:fork = $forkid]/wf:branch-status[./wf:branch = $branchid]/wf:status
        ,
        <wf:status>{$childStatus}</wf:status>
      )
      return
        <wf:synchronisation-details>
          <wf:message>Parent has been updated to reflect child branch instance's completion status</wf:message>
          <wf:parentProcessUri>{$parentProcessUri}</wf:parentProcessUri>
          <wf:childStatus>{$childStatus}</wf:childStatus>
          <wf:forkid>{$forkid}</wf:forkid>
          <wf:branchid>{$branchid}</wf:branchid>
          <wf:sent-status>{$childStatus}</wf:sent-status>
        </wf:synchronisation-details>
    else ()
  (: Update parent branch for this child instance :)
  (: DO NOT Check if parent complete - done in hasRendezvoused condition -
       (don't forget there will be 1 incomplete child - this process instance! ACID!) :)
  (: DO NOT Get parent wf:branches element (with me complete) and return for audit purposes - will break in ONE mode :)

};


















(:
 : The below has been replaced by an eval (m:evaluate), which bypasses the string replacement approach

declare function m:evaluateOLD($processUri as xs:string,$namespaces as element(wf:namespace)*,$xpath as xs:string) as xs:boolean {

  let $_ := xdmp:log("In wfu:evaluate")

  (: TODO handle version 8 javascript conditions :)
  let $xp :=
    if (fn:substring($xpath,1,1) = "/") then
      'fn:doc("' || $processUri || '")' || $xpath
    else
      $xpath

  (: replacements of shorthand variable names :)
  let $xp := fn:replace($xp,"\$wf:process/",'fn:doc("' || $processUri || '")/wf:process/')
  let $xp := fn:replace($xp, "\$processData/",'fn:doc("' || $processUri || '")/wf:process/wf:data/')

  let $_ := xdmp:log("wfu:evaluate: Condition: "||$xp)
  let $ns :=
    for $namespace in $namespaces
    return ($namespace/@short/text(),$namespace/@long/text())
  let $_ := xdmp:log("Namespaces:-")
  let $_ := xdmp:log($ns)

  let $result := xdmp:with-namespaces($ns, xdmp:eval('declare namespace wf="http://marklogic.com/workflow"; ' || $xp,(),()))
  let $_ := xdmp:log("wfu:evaluate: result:-")
  let $_ := xdmp:log($result)

  return
    $result
};
:)

(:
 : TODO WARNING - This function is vulnerable to XQuery injection attacks. It should be invoked with just enough
 : privileges such that it can read the single document (wf:process element) it is passed, and be read only.
 :)
declare function m:evaluate($processUri as xs:string,$namespaces as element(wf:namespace)*,$xpath as xs:string) {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  let $ns :=
    for $namespace in $namespaces
    return
      if (fn:not(fn:empty($namespace/@short/text())) and fn:not(fn:empty($namespace/@long/text()))) then
        "declare namespace " || $namespace/@short/text() || ' = "' || $namespace/@long/text() || '"; '
      else ""
  let $xquery :=
    'xquery version "1.0-ml";declare namespace wf="http://marklogic.com/workflow";' || $ns ||
    'declare variable $wf:process as element(wf:process) external;' ||
    $xpath
  let $_ := xdmp:log($xquery)
  return
    xdmp:eval($xquery,
      (xs:QName("wf:process"),fn:doc($processUri)/wf:process),
      <options xmlns="xdmp:eval">
        <isolation>different-transaction</isolation>
        <prevent-deadlocks>true</prevent-deadlocks>
      </options>
    ) (: NB prevent deadlocks ALSO prevents UPDATES. :)
};


(:
 : TODO WARNING - This function is vulnerable to XQuery injection attacks. It should be invoked with just enough
 : privileges such that it can read the single document (wf:process element) it is passed, and be read only.
 :)
declare function m:evaluateXml($processUri as xs:string,$namespaces as element(wf:namespace)*,$xmlText as xs:string,$params as node()*) as node()* {
  let $_secure := xdmp:security-assert($wfdefs:privRuntime, "execute")

  let $xquery := 'xquery version "1.0-ml";declare namespace wf="http://marklogic.com/workflow";' ||
      'declare variable $wf:process as element(wf:process) external;' || $xmlText
  let $_ := xdmp:log("wfu:evaluateXml: xquery: " || $xquery)
  let $result :=
   xdmp:eval($xquery,
      (xs:QName("wf:process"),fn:doc($processUri)/wf:process), (: TODO accept external params without having blank params of () in the eval call :)
      <options xmlns="xdmp:eval">
        <isolation>different-transaction</isolation>
        <prevent-deadlocks>true</prevent-deadlocks>
      </options>
    ) (: NB prevent deadlocks ALSO prevents UPDATES. :)
  let $_ := xdmp:log("wfu:evaluateXml: result:-")
  let $_ := xdmp:log($result)
  let $_ := xdmp:log("wfu:evaluateXml: Complete. Returning...")
  return $result
};
