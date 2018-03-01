xquery version "1.0-ml";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";

declare namespace wf="http://marklogic.com/workflow";
declare namespace prop = "http://marklogic.com/xdmp/property";

declare variable $cpf:document-uri as xs:string external;
declare variable $cpf:transition as node() external;
declare variable $cpf:options as element() external;

(:
 : Check for all property-update and document-update eventualities that mean we should restart the process.
 :)


try {
  let $_ := xdmp:log("MarkLogic Workflow restart CPF action called for: "||$cpf:document-uri)
  let $_ := xdmp:trace("ml-workflow","restart transition : "||xdmp:quote($cpf:transition))
  let $_ := xdmp:trace("ml-workflow","restart cpf:options : "||xdmp:quote($cpf:options))
  (: 1. Check for external task completion status (step-status = "COMPLETE") :)
  let $_ := xdmp:log("restart condition check for: " || $cpf:document-uri)
  let $complete as xs:boolean := xdmp:document-properties($cpf:document-uri)/prop:properties/wf:currentStep/wf:step-status eq $wfu:COMPLETE-STATUS
  let $forking as xs:boolean := xdmp:document-properties($cpf:document-uri)/prop:properties/wf:currentStep/wf:step-type = $wfu:FORK-STEP-TYPE
  let $_ := xdmp:log("Complete : "||$complete)
  let $_ := xdmp:log("Forking : "||$forking)  
  let $result as xs:boolean := $complete or $forking
  let $_ := xdmp:log($result)

  return
    if ($result) then

      let $props := xdmp:document-properties($cpf:document-uri)/prop:properties
      let $_ := xdmp:log($props)
      let $next := xs:string($props/wf:currentStep/wf:state)
      let $_ := xdmp:log("Next state: "||$next)
      let $startTime := xs:dateTime($props/wf:currentStep/wf:startTime)
      return wfu:complete( $cpf:document-uri, $cpf:transition, xs:anyURI($next), $startTime )
    else (
      xdmp:trace("ml-workflow","Restart - checking transition ..."),
      xdmp:trace("ml-workflow","Current props : "||xdmp:quote(xdmp:document-properties($cpf:document-uri)/prop:properties)),
      if (cpf:check-transition($cpf:document-uri,$cpf:transition)) then
        (
          cpf:document-set-last-updated( $cpf:document-uri, fn:current-dateTime() )
          ,
          cpf:success( $cpf:document-uri, $cpf:transition, () )
        )
      else ()

    ) (: do what CPF normally does... :)
} catch ($e) {
  wfu:failure( $cpf:document-uri, $cpf:transition, $e, () )
}
