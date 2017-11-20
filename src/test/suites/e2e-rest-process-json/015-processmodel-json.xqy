xquery version "1.0-ml";

(: 01-processmodel-create :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E JSON TEST: 01-processmodel-create")
let $process := wrt:processmodel-create ($const:json-options, "015-restapi-tests.bpmn")
return (
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/createResponse/outcome)),
  test:assert-equal('015-restapi-tests__1__0', xs:string($process[2]/createResponse/modelId))
);

(: 02-processmodel-read :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace http = "xdmp:http";
declare namespace bpmn2 = "http://www.omg.org/spec/BPMN/20100524/MODEL";

let $_testlog := xdmp:log("E2E JSON TEST: 02-processmodel-read")
let $result := wrt:test-02-processmodel-read($const:json-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('http://marklogic.com/workflow', xs:string($result[2]/bpmn2:definitions/bpmn2:import/@namespace))
);

(: 03-processmodel-update :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E JSON TEST: 03-processmodel-update")
let $result := wrt:test-03-processmodel-update($const:json-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/createResponse/outcome)),
  test:assert-equal('015-restapi-tests__1__2', xs:string($result[2]/createResponse/modelId))
);

(: 04-processmodel-publish :)

import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E JSON TEST: 04-processmodel-publish")
let $result := wrt:processmodel-publish($const:json-options, "015-restapi-tests__1__2")
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/updateResponse/outcome)),
  test:assert-exists(xs:string($result[2]/updateResponse/domainId))
);

(: 06-process-create :)

import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E JSON TEST: 06-process-create")
let $payload := doc("/raw/data/06-payload.xml")
let $result := wrt:process-create($const:json-options, $payload)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/createResponse/outcome)),
  test:assert-exists(xs:string($result[2]/createResponse/processId)),
  xdmp:document-insert("/test/processId.xml", <test><processId>{xs:string($result[2]/createResponse/processId)}</processId></test>),
  xdmp:log(fn:concat("processId:", xdmp:quote($result[2])))
);

(: 07-process-read :)

import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E JSON TEST: 07-process-read")
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:process-read($const:json-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/readResponse/outcome)),
  test:assert-exists($result[2]/readResponse/document)
);

(: 08-processinbox-read :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processinbox";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_testlog := xdmp:log("E2E JSON TEST: 08-processinbox-read")
let $_pause := xdmp:sleep(10000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-08-processinbox-read($const:json-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/readResponse/outcome)),
  test:assert-exists($result[2]/readResponse/inbox/task[processid=$pid]),
  let $task := $result[2]/readResponse/inbox/task[processid=$pid]
  return (
    test:assert-exists($task/processData/process/data),
    test:assert-exists($task/processData/process/attachments),
    test:assert-exists($task/processData/process/auditTrail),
    test:assert-exists($task/processData/process/metrics),
    test:assert-exists($task/processData/process/processDefinitionName),
    let $properties := $task/processProperties/properties
    return (
      test:assert-equal('done', xs:string($properties/processingStatus)),
      test:assert-equal('user', xs:string($properties/currentStep/type)),
      test:assert-equal('admin', xs:string($properties/currentStep/assignee)),
      test:assert-equal('userTask', xs:string($properties/currentStep/stepType)),
      test:assert-equal('ENTERED', xs:string($properties/currentStep/stepStatus))
    )
  )
);

(: 09-process-update :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E JSON TEST: 09-process-update")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-09-process-update($const:json-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/updateResponse/outcome))
);

(: 10-processqueue-read :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processqueue";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_testlog := xdmp:log("E2E JSON TEST: 10-processqueue-read")
let $result := wrt:test-10-processqueue-read($const:json-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/readResponse/outcome)),
  test:assert-exists($result[2]/readResponse/queue)
);

(: 11-process-update-lock - Attempt to lock unlocked task - should pass :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_testlog := xdmp:log("E2E JSON TEST: 11-process-update-lock")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-11-process-update-lock($const:json-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//outcome)),
  test:assert-exists($result[2]/readResponse/document)
);

(: 12-process-update-lock-fail - Attempt to lock locked task - should fail :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace error="http://marklogic.com/xdmp/error";

let $_testlog := xdmp:log("E2E JSON TEST: 12-process-update-lock-fail")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-12-process-update-lock-fail($const:json-failure-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('FAILURE', xs:string($result[2]//outcome)),
  test:assert-exists($result[2]/updateResponse/message)
);

(: 13-process-update-unlock - Attempt to unlock locked task - should pass :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace error="http://marklogic.com/xdmp/error";

let $_testlog := xdmp:log("E2E JSON TEST: 13-process-update-unlock")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-13-process-update-unlock($const:json-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//outcome)),
  test:assert-exists($result[2]/readResponse/document)
);

(: 14-process-update-lock - Attempt to lock unlocked task - should pass :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_testlog := xdmp:log("E2E JSON TEST: 14-process-update-lock")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-14-process-update-lock($const:json-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//outcome)),
  test:assert-exists($result[2]/readResponse/document)
);

(: 15-process-update :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E JSON TEST: 15-process-update")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-15-process-update($const:json-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/updateResponse/outcome))
);

(: 16-process-read :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E JSON TEST: 16-process-read")
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:process-read($const:json-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/readResponse/outcome)),
  test:assert-exists($result[2]/readResponse/document)
);



