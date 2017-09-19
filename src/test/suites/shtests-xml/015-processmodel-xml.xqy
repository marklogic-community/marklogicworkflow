xquery version "1.0-ml";

(: 01-processmodel-create :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

let $process := wrt:processmodel-create ($c:json-options, "015-restapi-tests.bpmn")
(: not working with XML ? :)
return ( (:
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('015-restapi-tests__1__0', xs:string($process[2]/ext:createResponse/ext:modelId)) :)
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/createResponse/outcome)),
  test:assert-equal('015-restapi-tests__1__0', xs:string($process[2]/createResponse/modelId))
);

(: 02-processmodel-read :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace http = "xdmp:http";
declare namespace bpmn2 = "http://www.omg.org/spec/BPMN/20100524/MODEL";

let $result := wrt:test-02-processmodel-read($c:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('http://marklogic.com/workflow', xs:string($result[2]/bpmn2:definitions/bpmn2:import/@namespace))
);

(: 03-processmodel-update :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

(: not working with XML ? :)
let $result := wrt:test-03-processmodel-update($c:json-options)
return ( (:
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('015-restapi-tests__1__2', xs:string($result[2]/ext:createResponse/ext:modelId)) :)
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/createResponse/outcome)),
  test:assert-equal('015-restapi-tests__1__2', xs:string($result[2]/createResponse/modelId))
);

(: 04-processmodel-publish :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

(: not working with XML ? :)
let $result := wrt:processmodel-publish($c:json-options, "015-restapi-tests__1__2")
return ( (:
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:updateResponse/ext:outcome)),
  test:assert-exists(xs:string($result[2]/ext:updateResponse/ext:domainId)) :)
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/updateResponse/outcome)),
  test:assert-exists(xs:string($result[2]/updateResponse/domainId))
);

(: there is and has never been 05 :)

(: 06-process-create :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $payload := doc("/raw/data/06-payload.xml")
let $result := wrt:process-create($c:xml-options, $payload)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:createResponse/ext:outcome)),
  test:assert-exists(xs:string($result[2]/ext:createResponse/ext:processId)),
  xdmp:document-insert("/test/processId.xml", <test><processId>{xs:string($result[2]/ext:createResponse/ext:processId)}</processId></test>),
  xdmp:log(fn:concat("processId:", xdmp:quote($result[2])))
);

(: 07-process-read :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:process-read($c:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document)
);

(: 08-processinbox-read :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processinbox";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-08-processinbox-read($c:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/wf:inbox/wf:task[@processid=$pid])
);

(: 09-process-update :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-09-process-update($c:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:updateResponse/ext:outcome))
);

(: 10-processqueue-read :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processqueue";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $result := wrt:test-10-processqueue-read($c:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/wf:queue)
);

(: 11-process-update-lock - Attempt to lock unlocked task - should pass :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-11-process-update-lock($c:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document/wf:process)
);

(: 12-process-update-lock-fail - Attempt to lock locked task - should fail : )
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace error="http://marklogic.com/xdmp/error";

let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-12-process-update-lock-fail($c:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('FAILURE', xs:string($result[2]//ext:outcome)), ( : currently passing !?! : )
  test:assert-exists($result[2]/ext:updateResponse/ext:message)
); :)

(: 13-process-update-unlock - Attempt to unlock locked task - should pass :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-13-process-update-unlock($c:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document/wf:process)
);

(: 14-process-update-lock - Attempt to lock unlocked task - should pass :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";
declare namespace wf="http://marklogic.com/workflow";

let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-14-process-update-lock($c:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document/wf:process)
);

(: 15-process-update :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $_pause := xdmp:sleep(5000)
let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:test-15-process-update($c:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]//ext:outcome))
);

(: 16-process-read :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:process-read($c:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document)
);
(: let $_pause := xdmp:sleep(5000) :)

