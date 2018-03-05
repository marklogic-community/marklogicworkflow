xquery version "1.0-ml";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";

declare namespace wf = "http://marklogic.com/workflow";
declare namespace p="http://marklogic.com/cpf/pipelines";

declare variable $cpf:document-uri as xs:string external;
declare variable $cpf:transition as node() external;
declare variable $cpf:options as element() external;

let $cpf:state := xdmp:document-properties($cpf:document-uri)/prop:properties/cpf:state/text()
let $cpf:transition := /p:pipeline/p:state-transition[p:state = $cpf:state]
let $module := $cpf:transition/p:execute/p:action/p:module/text()
let $module-options := $cpf:transition/p:execute/p:action/*[fn:local-name(.) = "options"][fn:namespace-uri(.) = $module]

let $condition-check-module := $cpf:transition/p:execute/p:condition/p:module/text()
let $condition-check-options := $cpf:transition/p:execute/p:condition/*[fn:local-name(.) = "options"][fn:namespace-uri(.) = $condition-check-module]
let $condition-check-result := 
xdmp:invoke($condition-check-module,(xs:QName("cpf:document-uri"),$cpf:document-uri,xs:QName("cpf:transition"),$cpf:transition,xs:QName("cpf:options"),$condition-check-options))
return
if($condition-check-result) then
	xdmp:invoke($module,(xs:QName("cpf:document-uri"),$cpf:document-uri,xs:QName("cpf:transition"),$cpf:transition,xs:QName("cpf:options"),$module-options))
else
()
