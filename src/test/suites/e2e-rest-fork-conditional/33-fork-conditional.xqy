xquery version "1.0-ml";

(: 33-processmodel-create-fork-conditional :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

let $_pause := xdmp:sleep(5000)
let $process := wrt:processmodel-create ($const:json-options, "fork-conditional.bpmn2")
(: not working with XML ? :)
return ( (:
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('015-restapi-tests__1__0', xs:string($process[2]/ext:createResponse/ext:modelId)) :)
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/createResponse/outcome)),
  test:assert-equal('fork-conditional__1__0', xs:string($process[2]/createResponse/modelId))
);

(:
  {
    "createResponse": {
      "outcome": "SUCCESS",
      "modelId": "fork-conditional__1__0/Task_2"
    }
  }
:)

(: 35-processmodel-publish-fork-simple :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

(: not working with XML ? :)
let $result := wrt:processmodel-publish($const:json-options, "fork-conditional__1__0")
return ( (:
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:updateResponse/ext:outcome)),
  test:assert-exists(xs:string($result[2]/ext:updateResponse/ext:domainId)) :)
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/updateResponse/outcome)),
  test:assert-exists(xs:string($result[2]/updateResponse/domainId))
);

import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
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




(: let $_pause := xdmp:sleep(5000) :)
(: All the below are final tests, to be executed at the end of all tests only :)

(: 91-processengine-read :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processengine";
declare namespace http = "xdmp:http";
declare namespace wf = "http://marklogic.com/workflow";

let $result := wrt:test-91-processengine-read($const:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/wf:processes)
);




