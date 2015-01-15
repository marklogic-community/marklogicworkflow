xquery version "1.0-ml";

declare module namespace m="http://marklogic.com/scxmltocpf";

declare namespace sc="http://www.w3.org/2005/07/scxml";

(:
 : See http://www.w3.org/TR/scxml/
 :)

declare function m:scxml-to-cpf($processmodeluri as xs:string,$doc as element(sc:scxml)) as xs:string {
  (: Convert the SCXML process model to a CPF pipeline :)
  let $initial :=
    if (fn:not(fn:empty($doc/@initial))) then
      $doc/sc:state[./@id = $doc/@initial]
    else
      $doc/sc:state[1]

  (: create entry CPF action :)
  (: Link to initial state action :)
  let $pipelinexml :=
    <pipeline xmlns="http://marklogic.com/cpf/pipelines">
      <pipeline-name>Extended Copyright Pipeline</pipeline-name>
      <pipeline-description>Pipeline to test CPF</pipeline-description>
      <success-action>
        <module>/MarkLogic/cpf/actions/success-action.xqy</module> <!-- customise for workflow? -->
      </success-action>
      <failure-action>
        <module>/MarkLogic/cpf/actions/failure-action.xqy</module> <!-- customise for workflow? -->
      </failure-action>

      <state-transition>
        <annotation>Standard placeholder for initial state</annotation>
        <state>http://marklogic.com/states/initial</state>
        <on-success>http://marklogic.com/states{$processmodeluri}/{xs:string($initial/@id)}</on-success>
        <on-failure>http://marklogic.com/states/error</on-failure>
      </state-transition>

      {
        for $state in $doc/sc:state
        return

      <state-transition xmlns="http://marklogic.com/cpf/pipelines">
        <annotation>
          When a document containing ‘book’ as a root element is created,
          add a ‘copyright’ statement.
        </annotation>
        <state>http://marklogic.com/states{$processmodeluri}/{xs:string($state/@id)}</state>
        <on-success>http://marklogic.com/states{$processmodeluri}/{xs:string($state/sc:transition/@target)}</on-success>
        <on-failure>http://marklogic.com/states/error</on-failure>

        {
          if fn:false() then

    <execute>
      <condition>
        <module>/MarkLogic/cpf/actions/namespace-condition.xqy</module>
        <options xmlns="/MarkLogic/cpf/actions/namespace-condition.xqy">
          <root-element>book</root-element>
          <namespace/>
        </options>
      </condition>
      <action>
        <module>add-copyright.xqy</module>
      </action>
    </execute>

          else ()
        }
      </state-transition>
      }


      <state-transition>
        <annotation>Standard placeholder for final state</annotation>
        <state>http://marklogic.com/states{$processmodeluri}/{xs:string($doc/sc:final/@id)}</state>
        <on-success>http://marklogic.com/states/done</on-success>
        <on-failure>http://marklogic.com/states/error</on-failure>
      </state-transition>


    </pipeline>

};
