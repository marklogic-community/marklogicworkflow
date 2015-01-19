xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow";

declare namespace sc="http://www.w3.org/2005/07/scxml";
declare namespace b2="http://www.omg.org/spec/BPMN/20100524/MODEL";

import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";
import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";


import module namespace ss = "http://marklogic.com/alerts/alerts" at "/app/models/lib-alerts.xqy";


(: REST API OR XQUERY PUBLIC API FUNCTIONS :)


declare function m:convert-to-cpf($processmodeluri as xs:string,$major as xs:string,$minor as xs:string) as xs:unsignedLong {
  (: Find document :)

  (: Determine type from root element :)
  let $localPipelineId :=
    xdmp:eval('xquery version "1.0-ml";import module namespace m="http://marklogic.com/workflow" at "/app/models/workflow.xqy";declare variable $m:processmodeluri as xs:string external;declare variable $m:major as xs:string external;declare variable $m:minor as xs:string external;m:create($m:processmodeluri,$m:major,$m:minor)',
      (xs:QName("m:processmodeluri"),$processmodeluri,xs:QName("m:major"),$major,xs:QName("m:minor"),$minor),
      <options xmlns="xdmp:eval">
        <isolation>different-transaction</isolation>
      </options>
    )

  let $puri := "http://marklogic.com/cpf/pipelines/"||xs:string($localPipelineId)||".xml"
  let $pid :=
    xdmp:eval('xquery version "1.0-ml";import module namespace m="http://marklogic.com/workflow" at "/app/models/workflow.xqy";declare variable $m:puri as xs:string external;m:install($m:puri)',
      (xs:QName("m:puri"),$puri),
      <options xmlns="xdmp:eval">
        <isolation>different-transaction</isolation>
      </options>
    )

  let $dom := m:domain($processmodeluri,$major,$minor,$pid)


  return $pid

};


declare function m:subscribe-process($subscriptionName as xs:string, $processuri as xs:string,$query as element(cts:query)) as xs:unsignedLong {
  (: TODO remove existing config with same subscription name, if it exists :)
  ss:add-alert($subscriptionName,$query,(),"/app/models/action-process.xqy",xdmp:modules-database(),
    <process-name>{$processuri}</process-name>)
};






(: INTERNAL PRIVATE FUNCTIONS :)

declare function m:create($processmodeluri as xs:string,$major as xs:string,$minor as xs:string) as xs:unsignedLong {

  let $root := fn:doc($processmodeluri)/element()

  let $_ := xdmp:log("local name: "||fn:local-name($root)||" namespace: "||fn:namespace-uri($root))

  return

    if (fn:local-name($root) = 'scxml' and fn:namespace-uri($root) = 'http://www.w3.org/2005/07/scxml') then
      (: Call appropriate conversion function :)

      (xdmp:log("got scxml"),m:scxml-to-cpf($processmodeluri,$major,$minor,$root))

    else if (fn:local-name($root) = 'definitions' and fn:namespace-uri($root) = 'http://www.omg.org/spec/BPMN/20100524/MODEL') then

      (xdmp:log("got bpmn2"),m:bpmn2-to-cpf($processmodeluri,$major,$minor,$root))

      else
        (: if not supported throw an error :)
        (xdmp:log("got unknown"),0)

};

declare function m:install($puri as xs:string) as xs:unsignedLong {
  let $pxml := fn:doc($puri)/p:pipeline

  (: check if pipeline already exists, and recreate :)
  let $remove :=
    if (fn:not(fn:empty(p:get($puri)))) then
      xdmp:eval('xquery version "1.0-ml";declare namespace m="http://marklogic.com/workflow"; import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";declare variable $m:puri as xs:string external;p:remove($m:puri)',
        (xs:QName("m:puri"),$puri),
        <options xmlns="xdmp:eval">
          <database>{xdmp:triggers-database()}</database>
          <isolation>different-transaction</isolation>
        </options>
      )
    else
      ()

  (: Recreate pipeline :)
  return
    xdmp:eval('xquery version "1.0-ml";declare namespace m="http://marklogic.com/workflow"; import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";declare variable $m:pxml as element(p:pipeline) external;p:insert($m:pxml)',
      (xs:QName("m:pxml"),$pxml),
      <options xmlns="xdmp:eval">
        <database>{xdmp:triggers-database()}</database>
        <isolation>different-transaction</isolation>
      </options>
    )
};


declare function m:domain($processmodeluri as xs:string,$major as xs:string,$minor as xs:string,$pid as xs:unsignedLong) as xs:unsignedLong {
  (: let $pname := $processmodeluri||"__"||$major||"__"||$minor :)
  (: TODO Add all OOTB CPF pipelines to this domain too :)

  let $mdb := xdmp:modules-database()

  (: check if domain already exists and recreate :)
  let $remove :=
    if (fn:not(fn:empty(dom:get($processmodeluri))) then
      xdmp:eval(
        'xquery version "1.0-ml";declare namespace m="http://marklogic.com/workflow"; import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";declare variable $m:processmodeluri as xs:string external;'
        ||
        'dom:remove($m:processmodeluri)'
        ,
        (xs:QName("m:processmodeluri"),$processmodeluri),
        <options xmlns="xdmp:eval">
          <database>{xdmp:triggers-database()}</database>
          <isolation>different-transaction</isolation>
        </options>
      )
    else
      ()

  (: Configure domain :)
  return
    xdmp:eval(
      'xquery version "1.0-ml";declare namespace m="http://marklogic.com/workflow"; import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";declare variable $m:processmodeluri as xs:string external;declare variable $m:pid as xs:unsignedLong external;declare variable $m:mdb as xs:unsignedLong external;'
      ||
      'dom:create($m:processmodeluri,"Execute process given a process data document for "||$m:processmodeluri,dom:domain-scope("directory","/workflow/processes"||$m:processmodeluri||"/","0"),dom:evaluation-context($m:mdb,"/"),($m:pid),())'
      ,
      (xs:QName("m:processmodeluri"),$processmodeluri,xs:QName("m:pid"),$pid,xs:QName("m:mdb"),$mdb),
      <options xmlns="xdmp:eval">
        <database>{xdmp:triggers-database()}</database>
        <isolation>different-transaction</isolation>
      </options>
    )
};











(: SOURCE CONVERSION FUNCTIONS :)

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

  let $failureAction := p:action("/MarkLogic/cpf/actions/failure-action.xqy",(),())
  let $failureState := xs:anyURI("http://marklogic.com/states/error")

  (: create entry CPF action :)
  (: Link to initial state action :)

  return
    p:create($pname,$pname,
      p:action("/MarkLogic/cpf/actions/success-action.xqy",(),()),
      $failureAction,(),
      (
          p:state-transition(xs:anyURI("http://marklogic.com/states/initial"),
            "Standard placeholder for initial state",xs:anyURI("http://marklogic.com/states"||$pname||"/"||xs:string($initial/@id)),
            $failureState,(),(),()
          )
          ,

          for $state in $doc/sc:state
          return
            p:state-transition(xs:anyURI("http://marklogic.com/states"||$pname||"/"||xs:string($state/@id)),
              "",xs:anyURI("http://marklogic.com/states"||$pname||"/"||xs:string($state/sc:transition/@target) ),
              $failureState,(),(),()
            )

          ,
          p:state-transition(xs:anyURI("http://marklogic.com/states"||$pname||"/"||xs:string($doc/sc:final/@id) ),
            "Standard placeholder for final state",xs:anyURI("http://marklogic.com/states/done"),
            $failureState,(),(),()
          )
      ) (: state transition list :)
    ) (: pcreate :)

};














(:
Example:-

<bpmn2:definitions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:bpmn2="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:dc="http://www.omg.org/spec/DD/20100524/DC" xmlns:di="http://www.omg.org/spec/DD/20100524/DI" id="Definitions_1" targetNamespace="http://marklogic.com/workflow">
  <bpmn2:process id="two_sample_transitions" name="Default Process">
    <bpmn2:startEvent id="StartEvent_1" name="Start">
      <bpmn2:outgoing>SequenceFlow_2</bpmn2:outgoing>
    </bpmn2:startEvent>
    <bpmn2:sequenceFlow id="SequenceFlow_2" sourceRef="StartEvent_1" targetRef="Task_1"/>
    <bpmn2:task id="Task_2" name="InProgress">
      <bpmn2:incoming>SequenceFlow_3</bpmn2:incoming>
      <bpmn2:outgoing>SequenceFlow_4</bpmn2:outgoing>
    </bpmn2:task>
    <bpmn2:sequenceFlow id="SequenceFlow_4" sourceRef="Task_2" targetRef="Task_3"/>
    <bpmn2:task id="Task_1" name="Open">
      <bpmn2:incoming>SequenceFlow_2</bpmn2:incoming>
      <bpmn2:outgoing>SequenceFlow_3</bpmn2:outgoing>
    </bpmn2:task>
    <bpmn2:sequenceFlow id="SequenceFlow_3" sourceRef="Task_1" targetRef="Task_2"/>
    <bpmn2:task id="Task_3" name="Closed">
      <bpmn2:incoming>SequenceFlow_4</bpmn2:incoming>
      <bpmn2:outgoing>SequenceFlow_5</bpmn2:outgoing>
    </bpmn2:task>
    <bpmn2:sequenceFlow id="SequenceFlow_5" sourceRef="Task_3" targetRef="EndEvent_1"/>
    <bpmn2:endEvent id="EndEvent_1" name="Finish">
      <bpmn2:incoming>SequenceFlow_5</bpmn2:incoming>
    </bpmn2:endEvent>
  </bpmn2:process>
:)


declare function m:bpmn2-to-cpf($processmodeluri as xs:string,$major as xs:string,$minor as xs:string,$doc as element(b2:definitions)) as xs:unsignedLong  {
  (: Convert the process model to a CPF pipeline and insert (create or replace) :)
  let $start := $doc/b2:process[1]
  let $initial := $start/b2:task[./@id = $start/b2:sequenceFlow[./@id = $doc/b2:process/b2:startEvent/b2:outgoing]/@targetRef]

  (: NB major and minor version not needed because this forms part of the process model document URI :)

  (: remove start and extension to get pname - /processengine/models/NAME/MAJOR/MINOR/model.xml :)
  let $pname := $processmodeluri||"__"||$major||"__"||$minor

  let $failureAction := p:action("/MarkLogic/cpf/actions/failure-action.xqy",(),())
  let $failureState := xs:anyURI("http://marklogic.com/states/error")

  (: create entry CPF action :)
  (: Link to initial state action :)

  return
    p:create($pname,$pname,
      p:action("/MarkLogic/cpf/actions/success-action.xqy",(),()),
      $failureAction,(),
      (
          p:state-transition(xs:anyURI("http://marklogic.com/states/initial"),
            "Standard placeholder for initial state",xs:anyURI("http://marklogic.com/states"||$pname||"/"||xs:string($initial/@id)),
            $failureState,(),(),()
          )
          ,

          for $state in $doc/sc:state
          return
            p:state-transition(xs:anyURI("http://marklogic.com/states"||$pname||"/"||xs:string($state/@id)),
              "",xs:anyURI("http://marklogic.com/states"||$pname||"/"||xs:string($state/sc:transition/@target) ),
              $failureState,(),(),()
            )

          ,
          p:state-transition(xs:anyURI("http://marklogic.com/states"||$pname||"/"||xs:string($doc/sc:final/@id) ),
            "Standard placeholder for final state",xs:anyURI("http://marklogic.com/states/done"),
            $failureState,(),(),()
          )
      ) (: state transition list :)
    ) (: pcreate :)

};
