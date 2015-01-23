xquery version "1.0-ml";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/app/models/workflow-util.xqy";

declare namespace wf="http://marklogic.com/workflow";

declare variable $cpf:document-uri as xs:string external;
declare variable $cpf:transition as node() external;
declare variable $cpf:options as element() external;

(: Example CPF Pipeline XML:-
<state-transition>
  <annotation>BPMN2 Exclusive Gateway</annotation>
  <state>http://marklogic.com/states/PROCESSNAME__1__0/SomeStep</state>
  <!-- no on success -->
  <on-failure>http://marklogic.com/states/error</on-failure> <!-- could be a failure handling event step -->
  <execute>
    <action>
      <module>/app/workflowengine/actions/exclusiveGateway.xqy</module>
      <options xmlns="/app/workflowengine/actions/exclusiveGateway.xqy">
        <wf:namespaces>
          <wf:namespace short="xh" long="http://some/xml/ns" />
        </wf:namespaces>
        <wf:route xmlns:wf="http://marklogic.com/workflow">
          <wf:condition>fn:empty(/some/xpath/resulting/in/boolean)</wf:condition>
          <wf:state>http://marklogic.com/states/PROCESSNAME__1__0/RouteAFirstStep</wf:state>
          <wf:name>Route A</wf:name>
          <wf:description>Something from BPMN2 description field</wf:description>
        </wf:route>
        <wf:route xmlns:wf="http://marklogic.com/workflow">
          <wf:condition>fn:empty(/some/xpath/resulting/in/boolean)</wf:condition>
          <wf:state>http://marklogic.com/states/PROCESSNAME__1__0/RouteBFirstStep</wf:state>
          <wf:name>Route B</wf:name>
          <wf:description>Something from BPMN2 description field</wf:description>
        </wf:route>
        ...
      </options>
    </action>
  </execute>
</state-transition>

  (: TODO handle version 8 javascript conditions :)
:)

try {
  let $map := map:map()

  (: Evaluate each condition in turn :)
  let $_ :=
    for $route in $cpf:options/wf:route
    return
      if (fn:not(fn:empty(map:get($map,"route")))) then
        ()
      else
        if ($wfu:evaluate($cpf:document-uri,$route/wf:condition/text())) then
          (: If true, set route choice state :)
          map:put($map,"route",$route/wf:state/text())
        else
          ()
  let $_ :=
    if (fn:not(fn:empty($cpf:options/wf:default-route))) then
      (: If none return true, set state to default route state, if available :)
      map:put($map,"route",$cpf:options/wf:default-route/text())
    else
      ()

  (: If still none, throw failure message (misconfiguration) :)
  return
    if (fn:empty(map:get($map,"route"))) then
      wfu:failure($cpf:document-uri,$cpf-transition,"No route chosen out of exclusive gateway!")
    else
      wfu:complete( $cpf:document-uri, $cpf:transition, $nextState )
} catch ($e) {
  wfu:failure( $cpf:document-uri, $cpf:transition, $e, () )
}
