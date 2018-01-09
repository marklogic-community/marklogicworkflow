xquery version "1.0-ml";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";

declare namespace wf="http://marklogic.com/workflow";
declare namespace prop = "http://marklogic.com/xdmp/property";

declare variable $cpf:document-uri as xs:string external;
declare variable $cpf:transition as node() external;
declare variable $cpf:options as element() external;

try {
  let $st := fn:current-dateTime()
  let $_ := xdmp:log("MarkLogic Workflow initial selection action called for: "||$cpf:document-uri)

  (: determine next state by URI of the process document :)
  (:
    $cpf:document-uri examples:
      "/workflow/processes/fork-simple__1__0/7de22e90-9352-42a3-bc48-ea7fe17cc5e3-2018-01-08T13:34:20.458597Z.xml",
      "/workflow/processes/fork-simple__1__0/183c396d-f251-43e7-a947-f07245d9ea03-2018-01-09T10:37:25.7917Z.xml",
      "/workflow/processes/fork-simple__1__0/Task_1/7de22e90-9352-42a3-bc48-ea7fe17cc5e3-2018-01-08T13:34:20.458597Z.xml",
      "/workflow/processes/fork-simple__1__0/Task_2/183c396d-f251-43e7-a947-f07245d9ea03-2018-01-09T10:37:25.7917Z.xml",
      "/workflow/processes/fork-simple__1__0/Task_1/Task__3/7de22e90-9352-42a3-bc48-ea7fe17cc5e3-2018-01-08T13:34:20.458597Z.xml",
      "/workflow/processes/fork-simple__1__0/Task_2/Task__4/183c396d-f251-43e7-a947-f07245d9ea03-2018-01-09T10:37:25.7917Z.xml"
  :)
  let $split := fn:tokenize($cpf:document-uri, '/')
  let $last := fn:count($split) - 1
  let $middleName := fn:string-join(($split[4 to $last]), '/')
  let $_ := xdmp:log("Document is for process: " || $middleName)
  let $stateOverride := xs:anyURI("http://marklogic.com/states/" || $middleName || "__start")
  let $_ := xdmp:log("Next state is:-")
  let $_ := xdmp:log($stateOverride)

  (: Allow state transition to happen :)
  return wfu:complete( $cpf:document-uri, $cpf:transition, $stateOverride, $st )
} catch ($e) {
  wfu:failure( $cpf:document-uri, $cpf:transition, $e, () )
}
