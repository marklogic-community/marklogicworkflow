xquery version "1.0-ml";

(: 01-processmodel-create :)
import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

let $process := wrt:test-01-processmodel-create ($c:json-options)
return (
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

let $result := wrt:test-02-processmodel-read($c:json-options)
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

let $result := wrt:test-03-processmodel-update($c:json-options)
return (
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

let $result := wrt:test-04-processmodel-publish($c:json-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/updateResponse/outcome)),
  test:assert-exists(xs:string($result[2]/updateResponse/domainId))
);

(: 06-process-create :)

import module namespace c="http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

(: JSON not working ! :)

let $result := wrt:test-06-process-create($c:xml-options)
return (
(:
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/createResponse/outcome)),
  test:assert-exists(xs:string($result[2]/createResponse/processId)),
  xdmp:set-session-field("processId", xs:string($result[2]/createResponse/processId)),
  xdmp:log(fn:concat("processId:", xdmp:quote($result[2])))
  :)
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
let $result := wrt:test-07-process-read($c:json-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/readResponse/outcome)),
  test:assert-exists($result[2]/readResponse/document)
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
let $result := wrt:test-08-processinbox-read($c:json-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/readResponse/outcome)),
  test:assert-exists($result[2]/readResponse/inbox/task[processid=$pid])
);



(: let $_pause := xdmp:sleep(5000) :)


