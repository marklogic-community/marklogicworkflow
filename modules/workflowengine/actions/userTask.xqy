xquery version "1.0-ml";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/app/models/workflow-util.xqy";

declare namespace wf="http://marklogic.com/workflow";

declare variable $cpf:document-uri as xs:string external;
declare variable $cpf:transition as node() external;
declare variable $cpf:options as element() external;

(: A human (manual) task in a BPMN2 model. We wait at this state until moved onwards by the UI via the REST API

<state-transition>
  <annotation>Generic Task</annotation>
  <state>http://marklogic.com/states/PROCESSNAME__1__0/SomeStep</state>
  <!-- on-success is BLANK - we don't want to go forward automatically once complete -->
  <on-failure>http://marklogic.com/states/error</on-failure> <!-- could be a failure handling event step -->
  <execute>
    <action>
      <module>/workflowengine/actions/task.xqy</module>
      <options xmlns="/workflowengine/actions/task.xqy">
      </options>
    </action>
  </execute>
</state-transition>
:)

try {
  () (: Do nothing, but log the fact we are here :)
  
} catch ($e) {
  wfu:failure( $cpf:document-uri, $cpf:transition, $e, () )
}
