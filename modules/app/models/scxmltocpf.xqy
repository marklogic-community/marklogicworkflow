xquery version "1.0-ml";

declare module namespace m="http://marklogic.com/scxmltocpf";

declare namespace sc="http://www.w3.org/2005/07/scxml";

import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";

(:
 : See http://www.w3.org/TR/scxml/
 :)
declare function m:scxml-to-cpf($processmodeluri as xs:string,$major as xs:string,$minor as xs:string,$doc as element(sc:scxml)) as xs:unsignedLong  {
  (: Convert the SCXML process model to a CPF pipeline and insert (create or replace) :)
  let $initial :=
    if (fn:not(fn:empty($doc/@initial))) then
      $doc/sc:state[./@id = $doc/@initial]
    else
      $doc/sc:state[1]

  (: NB major and minor version not needed because this forms part of the process model document URI :)

  (: remove start and extension to get pname - /processengine/models/NAME/MAJOR/MINOR/model.xml :)
  let $pname := $processmodeluri||"__"||$major||"__"||$minor
  let $successAction :=
  let $failureAction := xs:anyURI("/MarkLogic/cpf/actions/failure-action.xqy")
  let $failureState := xs:anyURI("http://marklogic.com/states/error")

  (: create entry CPF action :)
  (: Link to initial state action :)

  return p:insert(
   p:create($pname,$pname,
    xs:anyURI("/MarkLogic/cpf/actions/success-action.xqy"),$failureAction,(),
    (
    p:state-transition(xs:anyURI("http://marklogic.com/states/initial"),
      "Standard placeholder for initial state",xs:anyURI("http://marklogic.com/states"||$pname||"/"||xs:string($initial/@id)),
      $failureState,(),(),()
    )
    ,
      {
        for $state in $doc/sc:state
        return
          p:state-transition(xs:anyURI("http://marklogic.com/states"||$pname||"/"||xs:string($state/@id)),
            "",xs:anyURI("http://marklogic.com/states"||$pname||"/"||xs:string($state/sc:transition/@target) ),
            $failureState,(),(),()
          )
      }
    ,
    p:state-transition(xs:anyURI("http://marklogic.com/states"||$pname||"/"||xs:string($doc/sc:final/@id) ),
      "Standard placeholder for final state",xs:anyURI("http://marklogic.com/states/done"),
      $failureState,(),(),()
    )
   )
  )






(:
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
    :)

};
