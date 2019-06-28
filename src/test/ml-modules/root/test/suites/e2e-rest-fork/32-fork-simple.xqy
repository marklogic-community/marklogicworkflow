xquery version "1.0-ml";

(: 32-processmodel-create-fork-simple :)
(: 1 - import bpmn and create model :)
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

let $process := wrt:processmodel-create ($const:json-options, "fork-simple.bpmn2")
(: not working with XML ? :)
return ( (:
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('015-restapi-tests__1__0', xs:string($process[2]/ext:createResponse/ext:modelId)) :)
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/createResponse/outcome)),
  test:assert-equal('fork-simple__1__0', xs:string($process[2]/createResponse/modelId))
);

(:
  {
    "createResponse": {
      "outcome": "SUCCESS",
      "modelId": "fork-simple__1__0/Task_1"
    }
  }
:)

(: 2 - publish model :)
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

(: not working with XML ? :)
let $result := wrt:processmodel-publish($const:json-options, "fork-simple__1__0")
return ( (:
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:updateResponse/ext:outcome)),
  test:assert-exists(xs:string($result[2]/ext:updateResponse/ext:domainId)) :)
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/updateResponse/outcome)),
  test:assert-exists(xs:string($result[2]/updateResponse/domainId))
);

(: 3 - check the pipelines :)
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
let $pipelines := cts:uri-match("http://marklogic.com/cpf/pipelines/*.xml")
return
  test:assert-equal(3, fn:count($pipelines))
;

(: 4 - create a new process :)
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $payload := doc("/raw/data/payload.xml")
let $result := wrt:process-create($const:xml-options, $payload)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:createResponse/ext:outcome)),
  test:assert-exists(xs:string($result[2]/ext:createResponse/ext:processId)),
  xdmp:document-insert("/test/processId.xml", <test><processId>{xs:string($result[2]/ext:createResponse/ext:processId)}</processId></test>),
  xdmp:log(fn:concat("processId:", xdmp:quote($result[2])))
);

xdmp:sleep(10000);

import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
test:assert-equal(3, (fn:count(cts:uri-match("/workflow/processes/fork-simple__1__0/*"))))
;


(: TODO: check the simple fork step 3 state here against the old ML forests :)

(: 4 - check parent process :)
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace cpf  = "http://marklogic.com/cpf";
declare namespace ext  = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace wf="http://marklogic.com/workflow";

let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:process-read-all($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document),
  let $properties := $result[2]/ext:readResponse/ext:properties
  return (
    test:assert-equal('RUNNING', xs:string($properties/prop:properties/wf:status)),
    test:assert-equal('INPROGRESS', xs:string($properties/prop:properties/wf:branches/wf:status)),
    test:assert-equal(1, fn:count($properties/prop:properties/wf:branches/wf:branch-status/wf:status[. = 'INPROGRESS'])),
    test:assert-exists(xs:string($properties/prop:properties/wf:branches/wf:fork)),
    let $forkid := xs:string($properties/prop:properties/wf:branches/wf:fork)
    let $fork1 := /wf:process[wf:forkid=$forkid][wf:branchid="fork-simple__1__0/Task_1"]
    let $fork2 := /wf:process[wf:forkid=$forkid][wf:branchid="fork-simple__1__0/Task_2"]
    return (
      xdmp:document-insert("/test/fork1ProcessId.xml", <test><processId>{xs:string($fork1/@id)}</processId></test>),
      xdmp:document-insert("/test/fork2ProcessId.xml", <test><processId>{xs:string($fork2/@id)}</processId></test>),
      test:assert-exists(xs:string($fork1/@id)),
      test:assert-exists(xs:string($fork2/@id))
    )
  )
);

(: 5 - check Task1 process :)
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace cpf  = "http://marklogic.com/cpf";
declare namespace ext  = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace wf="http://marklogic.com/workflow";

let $pid := xs:string(doc("/test/fork1ProcessId.xml")/test/processId)
let $result := wrt:process-read-all($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document),
  let $properties := $result[2]/ext:readResponse/ext:properties
  return (
    test:assert-equal('http://marklogic.com/states/fork-simple__1__0/Task_1/Task_1', xs:string($properties/prop:properties/cpf:state)),
    test:assert-equal('dynamicUser', xs:string($properties/prop:properties/wf:currentStep/wf:type)),
    test:assert-equal('http://marklogic.com/states/fork-simple__1__0/Task_1/Task_1__complete', xs:string($properties/prop:properties/wf:currentStep/wf:state)),
    test:assert-equal('userTask', xs:string($properties/prop:properties/wf:currentStep/wf:step-type)),
    test:assert-equal('ENTERED', xs:string($properties/prop:properties/wf:currentStep/wf:step-status))
  )
);

(: 6 - check Task2 process - Task 2 is automatic, so the path should be complete :)
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace cpf  = "http://marklogic.com/cpf";
declare namespace ext  = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace wf="http://marklogic.com/workflow";

let $pid := xs:string(doc("/test/fork2ProcessId.xml")/test/processId)
let $result := wrt:process-read-all($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document),
  let $properties := $result[2]/ext:readResponse/ext:properties
  return (
    test:assert-not-exists($properties/prop:properties/wf:currentStep),
    test:assert-equal('http://marklogic.com/states/done', xs:string($properties/prop:properties/cpf:state))
  )
);

(: 7 update Task1 process :)
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $pid := xs:string(doc("/test/fork1ProcessId.xml")/test/processId)
let $result := wrt:test-15-17-process-update($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//ext:outcome))
);

(: 8 - check Task1 process - path should be complete :)
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace cpf  = "http://marklogic.com/cpf";
declare namespace ext  = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace wf="http://marklogic.com/workflow";

let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/fork1ProcessId.xml")/test/processId)
let $result := wrt:process-read-all($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document),
  let $properties := $result[2]/ext:readResponse/ext:properties
  return (
    test:assert-not-exists($properties/prop:properties/wf:currentStep),
    test:assert-equal('http://marklogic.com/states/done', xs:string($properties/prop:properties/cpf:state))
  )
);

(: 9 - check parent process :)
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace cpf  = "http://marklogic.com/cpf";
declare namespace ext  = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace wf="http://marklogic.com/workflow";

let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:process-read-all($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document),
  let $properties := $result[2]/ext:readResponse/ext:properties
  return (
    test:assert-equal('COMPLETE', xs:string($properties/prop:properties/wf:status)), (: actually, we should have completed everything at this stage :)
    test:assert-equal('INPROGRESS', xs:string($properties/prop:properties/wf:branches/wf:status)),
    test:assert-equal(2, fn:count($properties/prop:properties/wf:branches/wf:branch-status/wf:status[. = 'COMPLETE']))
  )
);

(: let $_pause := xdmp:sleep(5000) :)
(: All the below are final tests, to be executed at the end of all tests only :)

(: 91-processengine-read : )
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processengine";
declare namespace http = "xdmp:http";
declare namespace wf = "http://marklogic.com/workflow";

let $result := wrt:test-91-processengine-read($const:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/wf:processes)
); :)




