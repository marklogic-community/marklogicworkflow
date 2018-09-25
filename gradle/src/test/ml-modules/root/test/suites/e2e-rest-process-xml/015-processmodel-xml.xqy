xquery version "1.0-ml";

(: 01-processmodel-create :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";


let $process := wrt:processmodel-create ($const:xml-options, "015-restapi-tests.bpmn")
let $_testlog := xdmp:log("E2E XML TEST: 01-processmodel-create")
return (
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('015-restapi-tests__1__0', xs:string($process[2]/ext:createResponse/ext:modelId))
);
(:
  <ext:createResponse xmlns:ext="http://marklogic.com/rest-api/resource/processmodel">
    <ext:outcome>SUCCESS</ext:outcome>
    <ext:modelId>015-restapi-tests__1__0</ext:modelId>
  </ext:createResponse>
:)

(: 02-processmodel-read :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace http = "xdmp:http";
declare namespace bpmn2 = "http://www.omg.org/spec/BPMN/20100524/MODEL";

let $_testlog := xdmp:log("E2E XML TEST: 02-processmodel-read")
let $result := wrt:test-02-processmodel-read($const:xml-options)
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


let $result := wrt:test-03-processmodel-update($const:xml-options)
let $_testlog := xdmp:log("E2E XML TEST: 03-processmodel-update")
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('015-restapi-tests__1__2', xs:string($result[2]/ext:createResponse/ext:modelId))
);
(:
  <ext:createResponse xmlns:ext="http://marklogic.com/rest-api/resource/processmodel">
    <ext:outcome>SUCCESS</ext:outcome>
    <ext:modelId>015-restapi-tests__1__2</ext:modelId>
  </ext:createResponse>
:)

(: 04-processmodel-publish :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E XML TEST: 04-processmodel-publish")
(: not working with XML ? :)
let $result := wrt:processmodel-publish($const:xml-options, "015-restapi-tests__1__2")
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:updateResponse/ext:outcome)),
  test:assert-exists(xs:string($result[2]/ext:updateResponse/ext:domainId))
);
(:
  <ext:updateResponse xmlns:ext="http://marklogic.com/rest-api/resource/processmodel">
    <ext:outcome>SUCCESS</ext:outcome>
    <ext:domainId>16663957717060497977</ext:domainId>
  </ext:updateResponse>
:)

(: there is and has never been 05 :)

(: 06-process-create :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E XML TEST: 06-process-create")
let $payload := doc("/raw/data/06-payload.xml")
let $result := wrt:process-create($const:xml-options, $payload)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:createResponse/ext:outcome)),
  test:assert-exists(xs:string($result[2]/ext:createResponse/ext:processId)),
  xdmp:document-insert("/test/processId.xml", <test><processId>{xs:string($result[2]/ext:createResponse/ext:processId)}</processId></test>),
  xdmp:log(fn:concat("processId:", xdmp:quote($result[2])))
);

(: 07-process-read :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E XML TEST: 07-process-read")
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:process-read($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document)
);
(:
  <ext:readResponse xmlns:ext="http://marklogic.com/rest-api/resource/process">
    <ext:outcome>SUCCESS</ext:outcome>
    <ext:document/>
  </ext:readResponse>
:)



(: 08-processinbox-read :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace cpf = "http://marklogic.com/cpf";
declare namespace ext = "http://marklogic.com/rest-api/resource/processinbox";
declare namespace http = "xdmp:http";
declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace wf="http://marklogic.com/workflow";

let $_testlog := xdmp:log("E2E XML TEST: 08-processinbox-read")
let $_pause := xdmp:sleep(10000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-08-processinbox-read($const:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/wf:inbox/wf:task[@processid=$pid]),
  let $task := $result[2]/ext:readResponse/wf:inbox/wf:task[@processid=$pid]
  return (
    test:assert-exists($task/wf:process-data/wf:process/wf:data),
    test:assert-exists($task/wf:process-data/wf:process/wf:attachments),
    test:assert-exists($task/wf:process-data/wf:process/wf:audit-trail),
    test:assert-exists($task/wf:process-data/wf:process/wf:metrics),
    test:assert-exists($task/wf:process-data/wf:process/wf:process-definition-name),
    let $properties := $task/wf:process-properties/prop:properties
    return (
      test:assert-equal('done', xs:string($properties/cpf:processing-status)),
      test:assert-equal('user', xs:string($properties/wf:currentStep/wf:type)),
      test:assert-equal('admin', xs:string($properties/wf:currentStep/wf:user)),
      test:assert-equal('userTask', xs:string($properties/wf:currentStep/wf:step-type)),
      test:assert-equal('ENTERED', xs:string($properties/wf:currentStep/wf:step-status))
    )
  )
);

(: 09-process-update :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E XML TEST: 09-process-update")
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-09-process-update($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:updateResponse/ext:outcome))
);

(: 10-processqueue-read :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processqueue";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_testlog := xdmp:log("E2E XML TEST: 10-processqueue-read")
let $result := wrt:test-10-processqueue-read($const:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/wf:queue)
);

(: 11-process-update-lock - Attempt to lock unlocked task - should pass :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_testlog := xdmp:log("E2E XML TEST: 11-process-update-lock")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-11-process-update-lock($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document/wf:process)
);

(: 12-process-update-lock-fail - Attempt to lock locked task - should fail :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace error="http://marklogic.com/xdmp/error";

let $_testlog := xdmp:log("E2E XML TEST: 12-process-update-lock-fail")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-12-process-update-lock-fail($const:xml-failure-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('FAILURE', xs:string($result[2]//ext:outcome)),
  test:assert-exists($result[2]/ext:updateResponse/ext:message)
);

(: 13-process-update-unlock - Attempt to unlock locked task - should pass :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_testlog := xdmp:log("E2E XML TEST: 13-process-update-unlock")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-13-process-update-unlock($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document/wf:process)
);

(: 14-process-update-lock - Attempt to lock unlocked task - should pass :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_testlog := xdmp:log("E2E XML TEST: 14-process-update-lock")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-14-process-update-lock($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document/wf:process)
);

(: 15-process-update :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E XML TEST: 15-process-update")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-15-17-process-update($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//ext:outcome))
);

(: 16-process-read :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E XML TEST: 16-process-read")
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:process-read($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document)
);

(: 17-process-update - should follow "with attachments" path :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $_testlog := xdmp:log("E2E XML TEST: 17-process-update")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-15-17-process-update($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//ext:outcome))
);

(: 18-process-read :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_testlog := xdmp:log("E2E XML TEST: 18-process-read")
let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:process-read($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document),
  test:assert-equal($pid, xs:string($result[2]/ext:readResponse/ext:document/wf:process/@id)),
  let $audit-trail := $result[2]/ext:readResponse/ext:document/wf:process/wf:audit-trail
  return (
    test:assert-exists($audit-trail/wf:audit[wf:state="http://marklogic.com/states/015-restapi-tests__1__2/ExclusiveGateway_1"][wf:description="Completed step"]),
    test:assert-exists($audit-trail/wf:audit[wf:state="http://marklogic.com/states/015-restapi-tests__1__2/Task_1"][wf:description="Completed step"]),
    test:assert-exists($audit-trail/wf:audit[wf:state="http://marklogic.com/states/015-restapi-tests__1__2/ExclusiveGateway_2"][wf:description="Completed step"]),
    test:assert-exists($audit-trail/wf:audit[wf:state="http://marklogic.com/states/015-restapi-tests__1__2/ExclusiveGateway_3"][wf:description="Completed step"]),
    test:assert-exists($audit-trail/wf:audit[wf:state="http://marklogic.com/states/015-restapi-tests__1__2/EndEvent_2"][wf:description="Completed step"])
  )
);


(: let $_pause := xdmp:sleep(5000) :)

(:

  TO DO: create tests for other steps:
    - with / without attachments
    - (with attachments) document property matches / doesn't match
    - date before / after 2000

:)
