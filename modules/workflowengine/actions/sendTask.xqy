xquery version "1.0-ml";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/app/models/workflow-util.xqy";

declare namespace wf="http://marklogic.com/workflow";

declare variable $cpf:document-uri as xs:string external;
declare variable $cpf:transition as node() external;
declare variable $cpf:options as element() external;

(: Example CPF Pipeline XML:-
<state-transition>
  <annotation>BPMN2 Send Email Message</annotation>
  <state>http://marklogic.com/states/PROCESSNAME__1__0/SomeStep</state>
  <!-- no on success -->
  <on-failure>http://marklogic.com/states/error</on-failure> <!-- could be a failure handling event step -->
  <execute>
    <action>
      <module>/workflowengine/actions/sendTask.xqy</module>
      <options xmlns="/workflowengine/actions/sendTask.xqy">
        <wf:namespaces>
          <wf:namespace short="xh" long="http://some/xml/ns" />
        </wf:namespaces>
        <wf:message xmlns:wf="http://marklogic.com/workflow">
          XML SMTP MESSSAGE FORMAT AS PER xdmp:email with {/wf:process/some/parameter} replacements.
        </wf:message>
      </options>
    </action>
  </execute>
</state-transition>
:)

try {
  let $map := map:map()
  let $st := fn:current-dateTime()

  let $ns := ($cpf:options/wf:namespaces/wf:namespace,<wf:namespace short="wf" long="http://marklogic.com/workflow" />)
  (: Default namespace is same as process doc :) (: TODO mix in those from BPMN2 doc :)

  let $message := $cpf:options/wf:message/node() (: XML send email format from xdmp:email :)

  (: TODO perform active parameter replacements withing text of email :)

  let $_ := xdmp:log("sendTask: Email message:-")
  let $_ := xdmp:log($message)


  (: If still none, throw failure message (misconfiguration) :)
  return
    (
      xdmp:email($message)
      ,
      wfu:complete( $cpf:document-uri, $cpf:transition, (), $st )
    )
} catch ($e) {
  wfu:failure( $cpf:document-uri, $cpf:transition, $e, () )
}
