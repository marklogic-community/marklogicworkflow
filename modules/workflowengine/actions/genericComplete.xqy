xquery version "1.0-ml";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/app/models/workflow-util.xqy";

declare namespace wf="http://marklogic.com/workflow";
declare namespace prop = "http://marklogic.com/xdmp/property";

declare variable $cpf:document-uri as xs:string external;
declare variable $cpf:transition as node() external;
declare variable $cpf:options as element() external;

try {
  let $props := xdmp:document-properties($cpf:document-uri)/prop:properties
  let $_ := xdmp:log($props)
  let $next := $cpf:options/wf:state/text()
  let $_ := xdmp:log($next)
  let $startTime := xs:dateTime($props/wf:currentStep/wf:startTime)
  return wfu:complete( $cpf:document-uri, $cpf:transition, $next, $startTime )
} catch ($e) {
  wfu:failure( $cpf:document-uri, $cpf:transition, $e, () )
}
