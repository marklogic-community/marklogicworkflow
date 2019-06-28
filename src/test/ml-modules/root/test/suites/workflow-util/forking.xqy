xquery version "1.0-ml";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";

declare namespace wf="http://marklogic.com/workflow";
declare namespace prop = "http://marklogic.com/xdmp/property";

let $document-uri := "/workflow/processes/fork-simple__1__0/4daff6c3-aba5-4c02-bf38-6cf1bcb8d44c-2018-01-09T16:23:48.244058Z.xml"
let $options := <opt:options xmlns:p="http://marklogic.com/cpf/pipelines" xmlns:opt="/workflowengine/actions/fork.xqy">
  <wf:branch-definitions xmlns:wf="http://marklogic.com/workflow">
    <wf:branch-definition>
      <wf:pipeline>fork-simple__1__0</wf:pipeline>
      <wf:branch>fork-simple__1__0/Task_1</wf:branch>
    </wf:branch-definition>
    <wf:branch-definition>
      <wf:pipeline>fork-simple__1__0</wf:pipeline>
      <wf:branch>fork-simple__1__0/Task_2</wf:branch>
    </wf:branch-definition>
    <wf:fork-method>ALL</wf:fork-method>
    <wf:rendezvous-method>ALL</wf:rendezvous-method>
  </wf:branch-definitions>
</opt:options>

(:
    if (fn:exists($options/wf:branches))
    then wfu:fork($document-uri,$options/wf:branches)
    else :)
let $fork := wfu:fork($document-uri,$options/wf:branch-definitions)
return $fork
;

import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace cpf  = "http://marklogic.com/cpf";
declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace wf="http://marklogic.com/workflow";

let $_pause := xdmp:sleep(10000)
let $process-uri := "/workflow/processes/fork-simple__1__0/4daff6c3-aba5-4c02-bf38-6cf1bcb8d44c-2018-01-09T16:23:48.244058Z.xml"
(: let $procdoc := doc($process-uri) :)
let $properties := xdmp:document-properties($process-uri)
return (
  test:assert-equal('INPROGRESS', xs:string($properties/prop:properties/wf:currentStep/wf:step-status)),
  test:assert-equal('fork', xs:string($properties/prop:properties/wf:currentStep/wf:step-type)),
  test:assert-equal('COMPLETE', xs:string($properties/prop:properties/wf:status)), (: RUNNING :)
  test:assert-equal('INPROGRESS', xs:string($properties/prop:properties/wf:branches/wf:status)),
  test:assert-equal(2, fn:count($properties/prop:properties/wf:branches/wf:branch-status/wf:status[. = 'INPROGRESS'])),
(:  test:assert-equal(1, fn:count($properties/prop:properties/wf:branches/wf:branch-status/wf:status[. = 'COMPLETE'])), :)
  test:assert-exists(xs:string($properties/prop:properties/wf:branches/wf:fork)),
  let $forkid := xs:string($properties/prop:properties/wf:branches/wf:fork)
  let $fork1 := /wf:process[wf:forkid=$forkid][wf:branchid="fork-simple__1__0/Task_1"]
  let $fork2 := /wf:process[wf:forkid=$forkid][wf:branchid="fork-simple__1__0/Task_2"]
  return (
    test:assert-exists(xs:string($fork1/@id)),
    test:assert-exists(xs:string($fork2/@id))
  )
);

(: TODO - more tests ! :)

(: 16-process-read : )
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:process-read($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document)
);
( : let $_pause := xdmp:sleep(5000) :)

