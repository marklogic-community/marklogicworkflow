xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow-import";
declare namespace wf="http://marklogic.com/workflow";

declare namespace sc="http://www.w3.org/2005/07/scxml";
declare namespace b2="http://www.omg.org/spec/BPMN/20100524/MODEL";


import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";
import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";


import module namespace ss = "http://marklogic.com/alerts/alerts" at "/app/models/lib-alerts.xqy";


(: REST API OR XQUERY PUBLIC API FUNCTIONS :)

declare function m:install-and-convert($doc as node(),$filename as xs:string,$major as xs:string,$minor as xs:string,$enable as xs:boolean?) as xs:string {
let $_ := xdmp:log("In wfi:install-and-convert")
  (: 1. Save document in to DB :)
  let $uri := "/workflow/models/" || $filename
  let $_ :=
    xdmp:eval('xquery version "1.0-ml";import module namespace m="http://marklogic.com/workflow-import" at "/app/models/workflow-import.xqy";declare variable $m:uri as xs:string external;declare variable $m:doc as node() external;'
      || 'xdmp:document-insert($m:uri,$m:doc,xdmp:default-permissions(),(xdmp:default-collections(),"http://marklogic.com/workflow/model"))'
      ,
      (xs:QName("m:uri"),$uri,xs:QName("m:doc"),$doc),
      <options xmlns="xdmp:eval">
        <isolation>different-transaction</isolation>
      </options>
    )
  (: 2. Convert to CPF :)
  let $resp := m:convert-to-cpf($uri,$major,$minor)
  let $dom :=
    if ($enable) then
      m:domain( (: $processmodeluri,$major,$minor, :) $resp,m:get-pipeline-id($resp)) (: Keep uri, major, minor here in case :)
      (: xdmp:log("In wfi:convert-to-cpf: domain: " || $dom) :)
    else
      ()

  return $resp
};

declare function m:enable($localPipelineId as xs:string) as xs:unsignedLong {
  m:domain($localPipelineId,m:get-pipeline-id($localPipelineId)) (: Keep uri, major, minor here in case :)
};

declare function m:get-model-by-name($name as xs:string) as node() {
  let $uri := "/workflow/models/" || $name
  return fn:doc($uri)
};


declare function m:convert-to-cpf($processmodeluri as xs:string,$major as xs:string,$minor as xs:string) as xs:string {
  (: Find document :)
  let $_ := xdmp:log("In wfi:convert-to-cpf")

  (: Determine type from root element :)
  let $localPipelineId :=
    xdmp:eval('xquery version "1.0-ml";import module namespace m="http://marklogic.com/workflow-import" at "/app/models/workflow-import.xqy";declare variable $m:processmodeluri as xs:string external;declare variable $m:major as xs:string external;declare variable $m:minor as xs:string external;m:create($m:processmodeluri,$m:major,$m:minor)',
      (xs:QName("m:processmodeluri"),$processmodeluri,xs:QName("m:major"),$major,xs:QName("m:minor"),$minor),
      <options xmlns="xdmp:eval">
        <isolation>different-transaction</isolation>
      </options>
    )
    let $_ := xdmp:log("In wfi:convert-to-cpf: pipeline id: " || $localPipelineId)

  (: let $puri := "http://marklogic.com/cpf/pipelines/"||xs:string($localPipelineId)||".xml" :)
  let $puri :=
    xdmp:eval('xquery version "1.0-ml";import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";import module namespace m="http://marklogic.com/workflow-import" at "/app/models/workflow-import.xqy";declare variable $m:id as xs:string external;p:get($m:id)/fn:base-uri(.)',
      (xs:QName("m:id"),$localPipelineId),
      <options xmlns="xdmp:eval">
        <isolation>different-transaction</isolation>
      </options>
    )
    let $_ := xdmp:log("In wfi:convert-to-cpf: puri: " || $puri)

  let $pid :=
    xdmp:eval('xquery version "1.0-ml";import module namespace m="http://marklogic.com/workflow-import" at "/app/models/workflow-import.xqy";declare variable $m:puri as xs:string external;m:install($m:puri)',
      (xs:QName("m:puri"),$puri),
      <options xmlns="xdmp:eval">
        <isolation>different-transaction</isolation>
      </options>
    )



  return $localPipelineId

};


declare function m:subscribe-process($subscriptionName as xs:string, $processuri as xs:string,$query as element(cts:query)) as xs:unsignedLong {
  (: TODO remove existing config with same subscription name, if it exists :)
  ss:add-alert($subscriptionName,$query,(),"/app/models/action-process.xqy",xdmp:modules-database(),
    <process-name>{$processuri}</process-name>)
};




declare function m:index-of-string
  ( $arg as xs:string? ,
    $substring as xs:string )  as xs:integer* {

  if (contains($arg, $substring))
  then (string-length(substring-before($arg, $substring))+1,
        for $other in
           m:index-of-string(substring-after($arg, $substring),
                               $substring)
        return
          $other +
          string-length(substring-before($arg, $substring)) +
          string-length($substring))
  else ()
 } ;







(: INTERNAL PRIVATE FUNCTIONS :)

declare function m:create($processmodeluri as xs:string,$major as xs:string,$minor as xs:string) as xs:string {
  let $_ := xdmp:log("In wfi:create")

  let $root := fn:doc($processmodeluri)/element()

  let $_ := xdmp:log("local name: "||fn:local-name($root)||" namespace: "||fn:namespace-uri($root))
  (:)
  let $pname := $processmodeluri||"__"||$major||"__"||$minor
  let $_ := xdmp:log("pname: " || $pname)
:)


let $max := m:index-of-string($processmodeluri,"/")[last()]

let $start := fn:substring($processmodeluri,$max + 1)

  let $shortname := fn:substring-before($start,".")



  let $name := $shortname || "__" || $major || "__" || $minor (: VERY IMPORTANT :)


  let $_ := xdmp:log("In wfi:create: name: " || $name)



  let $removeDoc :=
    try {
    if (fn:not(fn:empty(p:get($name)))) then
      xdmp:eval('xquery version "1.0-ml";declare namespace m="http://marklogic.com/workflow"; import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";declare variable $m:puri as xs:string external;p:remove($m:puri)',
        (xs:QName("wf:puri"),$name),
        <options xmlns="xdmp:eval">
          <database>{xdmp:database()}</database>
          <isolation>different-transaction</isolation>
        </options>
      )
    else
      ()
    } catch ($e) { () } (: catching pipeline throwing error if it doesn't exist. We can safely ignore this :)

  let $pid :=
        xdmp:eval('xquery version "1.0-ml";import module namespace m="http://marklogic.com/workflow-import" at "/app/models/workflow-import.xqy";'
          || 'declare variable $m:pname as xs:string external;'
          || 'declare variable $m:root as element() external;'
          || 'm:do-create($m:pname,$m:root)'
          ,
          (xs:QName("m:pname"),$name,xs:QName("m:root"),$root),
          <options xmlns="xdmp:eval">
            <database>{xdmp:database()}</database>
            <isolation>different-transaction</isolation>
          </options>
        ) (: TODO handle failure gracefully :)

  return
    $name


};

declare function m:get-pipeline-id($pname as xs:string) as xs:unsignedLong {
    xdmp:eval(
     'xquery version "1.0-ml";declare namespace m="http://marklogic.com/workflow"; ' ||
     'import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy"; ' ||
     'declare variable $m:processmodeluri as xs:string external; xs:unsignedLong(p:get($m:processmodeluri)/p:pipeline-id)'
     ,
      (xs:QName("wf:processmodeluri"),$pname),
      <options xmlns="xdmp:eval">
        <database>{xdmp:triggers-database()}</database>
        <isolation>different-transaction</isolation>
      </options>
    )
};

declare function m:do-create($pipelineName as xs:string,$root as element()) as xs:unsignedLong {
  let $_ := xdmp:log("In wfi:do-create: pipelineName: " || $pipelineName)
  return

    if (fn:local-name($root) = 'scxml' and fn:namespace-uri($root) = 'http://www.w3.org/2005/07/scxml') then
      (: Call appropriate conversion function :)

      (xdmp:log("got scxml"),m:scxml-to-cpf($pipelineName, $root))

    else if (fn:local-name($root) = 'definitions' and fn:namespace-uri($root) = 'http://www.omg.org/spec/BPMN/20100524/MODEL') then

      (xdmp:log("got bpmn2"),m:bpmn2-to-cpf($pipelineName,$root))

      else
        (: if not supported throw an error :)
        (xdmp:log("got unknown"),0)
};

declare function m:install($puri as xs:string) as xs:unsignedLong {
  let $_ := xdmp:log("In wfi:install: puri: " || $puri)
  let $pxml := fn:doc($puri)/p:pipeline

  (: check if pipeline already exists, and recreate :)
  let $remove :=
    try {
    if (fn:not(fn:empty(p:get($puri)))) then
      xdmp:eval('xquery version "1.0-ml";declare namespace m="http://marklogic.com/workflow"; import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";declare variable $m:puri as xs:string external;p:remove($m:puri)',
        (xs:QName("wf:puri"),$puri),
        <options xmlns="xdmp:eval">
          <database>{xdmp:triggers-database()}</database>
          <isolation>different-transaction</isolation>
        </options>
      )
    else
      ()
    } catch ($e) { () } (: catching pipeline throwing error if it doesn't exist. We can safely ignore this :)

  (: Recreate pipeline :)
  return
    xdmp:eval('xquery version "1.0-ml";declare namespace m="http://marklogic.com/workflow"; import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";declare variable $m:pxml as element(p:pipeline) external;p:insert($m:pxml)',
      (xs:QName("wf:pxml"),$pxml),
      <options xmlns="xdmp:eval">
        <database>{xdmp:triggers-database()}</database>
        <isolation>different-transaction</isolation>
      </options>
    )
};


declare function m:domain((: $processmodeluri as xs:string,$major as xs:string,$minor as xs:string, :) $pname as xs:string,$pid as xs:unsignedLong) as xs:unsignedLong {

  let $_ := xdmp:log("In wfi:domain")

  (: let $pname := $processmodeluri||"__"||$major||"__"||$minor :)
  (: TODO Add all OOTB CPF pipelines to this domain too :)

  let $mdb := xdmp:modules-database()
  let $_ := xdmp:log("pname: " || $pname || ", pid: " || xs:string($pid))

  (: check if domain already exists and recreate :)
  let $remove :=
    try {
    if (fn:not(fn:empty(
      xdmp:eval(
       'xquery version "1.0-ml";declare namespace m="http://marklogic.com/workflow"; import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";declare variable $m:processmodeluri as xs:string external; dom:get($m:processmodeluri)'
       ,
        (xs:QName("wf:processmodeluri"),$pname),
        <options xmlns="xdmp:eval">
          <database>{xdmp:triggers-database()}</database>
          <isolation>different-transaction</isolation>
        </options>
      )
     ))) then

     let $_ := xdmp:log(" GOT DOMAIN TO REMOVE")
     return
      xdmp:eval(
        'xquery version "1.0-ml";declare namespace m="http://marklogic.com/workflow"; import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";declare variable $m:processmodeluri as xs:string external;'
        ||
        'dom:remove($m:processmodeluri)'
        ,
        (xs:QName("wf:processmodeluri"),$pname),
        <options xmlns="xdmp:eval">
          <database>{xdmp:triggers-database()}</database>
          <isolation>different-transaction</isolation>
        </options>
      )
    else
      ()
    } catch ($e) { ( xdmp:log("Error trying to remove domain: " || $pname),xdmp:log($e) ) } (: catching domain throwing error if it doesn't exist. We can safely ignore this :)

  (: Configure domain :)
  return
    xdmp:eval(
      'xquery version "1.0-ml";declare namespace m="http://marklogic.com/workflow"; import module namespace p="http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy"; import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";declare variable $m:pname as xs:string external;declare variable $m:pid as xs:unsignedLong external;declare variable $m:mdb as xs:unsignedLong external;'
      ||
      'dom:create($m:pname,"Execute process given a process data document for "||$m:pname,'
      ||
      'dom:domain-scope("directory","/workflow/processes/"||$m:pname||"/","0"),dom:evaluation-context($m:mdb,"/"),(xs:unsignedLong(p:pipelines()[p:pipeline-name = "Status Change Handling"]/p:pipeline-id),$m:pid),())'
      ,
      (xs:QName("wf:pid"),$pid,xs:QName("wf:mdb"),$mdb,xs:QName("wf:pname"),$pname),
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
declare function m:scxml-to-cpf($pipelineName as xs:string, $doc as element(sc:scxml)) as xs:unsignedLong  {
  (: Convert the SCXML process model to a CPF pipeline and insert (create or replace) :)
  let $_ := xdmp:log("in m:scxml-to-cpf()")
  let $initial :=
    if (fn:not(fn:empty($doc/@initial))) then
      $doc/sc:state[./@id = $doc/@initial]
    else
      $doc/sc:state[1]

  (: NB major and minor version not needed because this forms part of the process model document URI :)

  (: remove start and extension to get pname - /processengine/models/NAME/MAJOR/MINOR/model.xml :)
  (: let $pname := $processmodeluri||"__"||$major||"__"||$minor :)

  let $failureAction := p:action("/MarkLogic/cpf/actions/failure-action.xqy",(),())
  let $failureState := xs:anyURI("http://marklogic.com/states/error")

  (: create entry CPF action :)
  (: Link to initial state action :)

  return
    p:create($pipelineName,$pipelineName,
      p:action("/MarkLogic/cpf/actions/success-action.xqy",(),()),
      $failureAction,(),
      (
          p:state-transition(xs:anyURI("http://marklogic.com/states/initial"),
            "Standard placeholder for initial state",xs:anyURI("http://marklogic.com/states/"||$pipelineName||"/"||xs:string($initial/@id)),
            $failureState,(),(),()
          )
          ,

          for $state in $doc/sc:state
          return
            p:state-transition(xs:anyURI("http://marklogic.com/states/"||$pipelineName||"/"||xs:string($state/@id)),
              "",xs:anyURI("http://marklogic.com/states/"||$pipelineName||"/"||xs:string($state/sc:transition/@target) ),
              $failureState,(),(),()
            )

          ,
          p:state-transition(xs:anyURI("http://marklogic.com/states/"||$pipelineName||"/"||xs:string($doc/sc:final/@id) ),
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


declare function m:bpmn2-to-cpf($pname as xs:string, $doc as element(b2:definitions)) as xs:unsignedLong  {
  (: Convert the process model to a CPF pipeline and insert (create or replace) :)
  let $_ := xdmp:log("in m:bpmn2-to-cpf()")
  let $start := $doc/b2:process[1]
  let $_ := xdmp:log($start)
  (: fixed below so start isn't necessarily the task - should it be the startEvent instead? :)
  let $initial := $start/b2:startEvent[1] (: is more than one valid? :)
  (: let $initial := $start/b2:task[./@id = $start/b2:sequenceFlow[./@id = $doc/b2:process/b2:startEvent/b2:outgoing]/@targetRef]:)

  (: NB major and minor version not needed because this forms part of the process model document URI :)

  (: remove start and extension to get pname - /processengine/models/NAME/MAJOR/MINOR/model.xml :)
  (: let $pname := $processmodeluri||"__"||$major||"__"||$minor :)

  let $failureAction := p:action("/MarkLogic/cpf/actions/failure-action.xqy",(),())
  let $failureState := xs:anyURI("http://marklogic.com/states/error")

  (: TODO determine if initial step is an incoming event step for Document Created or Document Updated event (alert has fired the process) :)


  return
    p:create($pname,$pname,
      p:action("/MarkLogic/cpf/actions/success-action.xqy",(),()),
      $failureAction,
      (
        p:status-transition("updated","Restart process on external action",() (: success :), $failureState,500,
          p:action("/workflowengine/actions/restart.xqy",
            "Check for restarting process.",() (: options :)
          )
          ,
          () (: rules :)
        )
      ) (: status transitions :)
      ,
      (

          (: create entry CPF action :)
          (: Link to initial state action :)
          p:state-transition(xs:anyURI("http://marklogic.com/states/initial"), (: TOP LEVEL PROCESS ONLY!!! :)
            "Standard placeholder for initial state",xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($initial/@id)),
            $failureState,(),(),()
          )

          ,

          (: 0. startEvent handling :)
          for $state in $start/b2:startEvent
          let $route := xs:string($state/b2:outgoing[1]) (: TODO support split here? :)
          let $rc :=
            if (fn:contains($route,":")) then
              fn:substring-after($route,":")
            else
              $route
          let $sf := $start/b2:sequenceFlow[./@id = $rc]
          return
            p:state-transition(xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($state/@id)),
              "",xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($sf/@targetRef) ),
              $failureState,(),
              p:action("/workflowengine/actions/startEvent.xqy","BPMN2 start event: "||xs:string($state/@name),
                  ()
                )
              ,
              ()
            )


          ,

          (: *** SPRINT 1: BASIC BPMN2 ACTIVITY SUPPORT *** :)

          (: 1. BPMN2 Generic task - handle as pass though only - no real implementation :)
          for $state in $start/b2:task
          let $route := xs:string($state/b2:outgoing[1]) (: TODO support split here? :)
          let $rc :=
            if (fn:contains($route,":")) then
              fn:substring-after($route,":")
            else
              $route
          let $sf := $start/b2:sequenceFlow[./@id = $rc]
          return
            p:state-transition(xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($state/@id)),
              "",xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($sf/@targetRef) ),
              $failureState,(),
              p:action("/workflowengine/actions/task.xqy","BPMN2 Task: "||xs:string($state/@name),
                  ()
                )
              ,
              ()
            )

          ,

          (: 2. BPMN2 exclusive gateways :)
          for $state in $start/b2:exclusiveGateway
          return

              p:state-transition(xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($state/@id)),
                "",(),
                $failureState,(),
                p:action("/workflowengine/actions/exclusiveGateway.xqy","BPMN2 Exclusive Gateway: "||xs:string($state/@name),
                  <p:options xmlns:p="http:marklogic.com/cpf/pipelines">
                    {
                      if (fn:not(fn:empty($state/@default))) then
                        let $sf := $start/b2:sequenceFlow[./@id = $state/@default]
                        return
                          <wf:default-route-state>{xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($sf/@targetRef))}</wf:default-route-state>
                      else ()
                    }
                    {
                      for $route in $state/b2:outgoing
                      let $rc :=
                        if (fn:contains($route,":")) then
                          fn:substring-after($route,":")
                        else
                          $route
                      let $sf := $start/b2:sequenceFlow[./@id = $rc]
                      return
                        <wf:route>
                          <wf:state>{xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($sf/@targetRef))}</wf:state>
                          <wf:name>{xs:string($sf/@name)}</wf:name>
                          <wf:condition language="{xs:string($sf/b2:conditionExpression[1]/@language)}">{$sf/b2:conditionExpression/text()}</wf:condition>
                        </wf:route>
                    }
                  </p:options>
                ),()
              )

          ,

          (: 3. BPMN2 end event activity :)
          for $state in $start/b2:endEvent
          return
            p:state-transition(xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($state/@id)),
              "",xs:anyURI("http://marklogic.com/states/"||$pname||"_end"),
              $failureState,(),
              p:action("/workflowengine/actions/endEvent.xqy","BPMN2 End Event: "||xs:string($state/@name),
                  ()
                )
              ,
              ()
            )

          ,

          (: 4. BPMN2 User (human step) task activity :)
          for $state in $start/b2:userTask
          let $type :=
            if ($state/b2:resourceRole/@name = "Assignee") then
              "user"
            else if ($state/b2:resourceRole/@name = "Queue") then
              "queue"
            else if ($state/b2:resourceRole/@name = "Role") then
              "role"
            else
              "unknown"
          let $userResource := ($state/b2:resourceRole[@name = "Assignee"])[1]/b2:resourceRef/text()
          let $user := xs:string($doc/b2:resource[@id = $userResource]/@name)
          let $queueResource := ($state/b2:resourceRole[@name = "Queue"])[1]/b2:resourceRef/text()
          let $queue := xs:string($doc/b2:resource[@id = $queueResource]/@name)
          let $roleResource := ($state/b2:resourceRole[@name = "Role"])[1]/b2:resourceRef/text()
          let $role := xs:string($doc/b2:resource[@id = $roleResource]/@name)

          let $route := xs:string($state/b2:outgoing[1]) (: TODO support split here? :)
          let $rc :=
            if (fn:contains($route,":")) then
              fn:substring-after($route,":")
            else
              $route
          let $sf := $start/b2:sequenceFlow[./@id = $rc]
          let $_ := xdmp:log("user task: " || xs:string($state/@id) || " out route: " || $route || ", target ref: " || xs:string($sf/@targetRef))
          return
            (p:state-transition(xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($state/@id)),
              "",(),
              $failureState,(), () (: empty default action :)
              ,
              ( (: execute set :)
                p:execute(
                  p:condition("/workflowengine/conditions/hasEntered.xqy","Check if just entered",())
                  ,
                  p:action("/workflowengine/actions/userTask.xqy","BPMN2 User Task: "||xs:string($state/@name),

                    <p:options xmlns:p="http:marklogic.com/cpf/pipelines">
                      <wf:type>{$type}</wf:type>
                      {
                        if (fn:not(fn:empty($user))) then <wf:assignee>{$user}</wf:assignee> else ()
                      }
                      {
                        if (fn:not(fn:empty($queue))) then <wf:queue>{$queue}</wf:queue> else ()
                      }
                      {
                        if (fn:not(fn:empty($role))) then <wf:role>{$role}</wf:role> else ()
                      }
                      <wf:state>{xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($state/@id)||"__complete")}</wf:state>
                    </p:options>
                  ) (: p action :)
                  ,"Apply set up user task action on entry"
                ) (: p:execute :)

                (:
                ,
                p:execute(
                  p:condition("/workflowengine/conditions/isComplete.xqy","Check if complete",())
                  ,
                  p:action("/workflowengine/actions/genericComplete.xqy",
                    "Wait for user completion: "||xs:string($state/@name),
                    <p:options xmlns:p="http:marklogic.com/cpf/pipelines">
                      <wf:state>{xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($sf/@targetRef))}</wf:state>
                    </p:options>
                  ),
                  "Apply default complete action"
                ) (: p execute :)
                :)


              ) (: execute set :)
            ) (: state transition :)
            ,
            (:
            p:state-transition(xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($state/@id)||"__inprogress"),
              "",(),
              $failureState,(),
              () (: empty default action :)
              ,
              (


              ) (: execute set :)
            )
            ,
            :)
            p:state-transition(xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($state/@id)||"__complete"),
              "",xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($sf/@targetRef)),
              $failureState,(),
              p:action("/workflowengine/actions/genericComplete.xqy",
                "User completion occurred: "||xs:string($state/@name),() (: options :)
              ) (: empty default action :)
              ,
              (


              ) (: execute set :)
            )
          ) (: state transition set :)


          ,

          (: Send email example - sendTask.xqy :)
          for $state in $start/b2:sendTask
          let $messageText := xs:string($doc/b2:message[@id = $state/@messageRef]/@name)
          (:
          let $item := $doc/b2:itemDefinition[@id = $message/@itemRef]
          let $structureRef := xs:string($item/@structureRef)

          let $operation := $doc/b2:interface/b2:operation[@id = $state/@operationRef]
          :)

          let $route := xs:string($state/b2:outgoing[1]) (: TODO support split here? :)
          let $rc :=
            if (fn:contains($route,":")) then
              fn:substring-after($route,":")
            else
              $route
          let $sf := $start/b2:sequenceFlow[./@id = $rc]
          return
              p:state-transition(xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($state/@id)),
                "",xs:anyURI("http://marklogic.com/states/"||$pname||"/"||xs:string($sf/@targetRef)),
                $failureState,(),
                p:action("/workflowengine/actions/sendTask.xqy","BPMN2 Send Task: "||xs:string($state/@name),
                  <options xmlns="/workflowengine/actions/sendTask.xqy">
                    <wf:message>{$messageText}</wf:message>
                  </options>
                ),()
              )

          ,








          (: DEV ADD YOUR CUSTOM TASK DEFINITION IMPORTS ABOVE HERE!!! BE SURE TO NOT FORGET THE TRAILING COMMA!!! :)










          (: *** TODO SPRINT 2: CPF CUSTOM ACTIVITY SUPPORT *** :)

          (: *** TODO SPRINT 3: ADVANCED BPMN2 PROCESS ORCHESTRATION ACTIVITY SUPPORT *** :)

          (: *** TODO SPRINT 4: ADVANCED EVENT DRIVEN ACTIVITY SUPPORT *** :)

          (: *** TODO SPRINT 5: MARKLOGIC DOCUMENT AND SEARCH CUSTOM ACTIVITY SUPPORT *** :)

          (: X. finally now route to the done state in CPF :)
          p:state-transition(xs:anyURI("http://marklogic.com/states/"||$pname||"__end"),
            "Standard placeholder for final state",xs:anyURI("http://marklogic.com/states/done"),
            $failureState,(),(),()
          )

      ) (: state transition list :)
    ) (: pcreate :)

};
