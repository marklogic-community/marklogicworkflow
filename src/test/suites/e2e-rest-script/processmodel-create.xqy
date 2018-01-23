xquery version "1.0-ml";

(: 21-processmodel-create :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

let $process := wrt:processmodel-create ($const:json-options, "script-test.bpmn")
(: not working with XML ? :)
return ( (:
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('015-restapi-tests__1__0', xs:string($process[2]/ext:createResponse/ext:modelId)) :)
  test:assert-equal('200', xs:string($process[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($process[2]/createResponse/outcome)),
  test:assert-equal('script-test__1__0', xs:string($process[2]/createResponse/modelId))
);

(: 22-processmodel-publish :)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processmodel";
declare namespace http = "xdmp:http";

(: not working with XML ? :)
let $result := wrt:processmodel-publish($const:json-options, "script-test__1__0")
return ( (:
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:updateResponse/ext:outcome)),
  test:assert-exists(xs:string($result[2]/ext:updateResponse/ext:domainId)) :)
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/updateResponse/outcome)),
  test:assert-exists(xs:string($result[2]/updateResponse/domainId))
);

(: Note that the scriptTask process doesn't have an import function yet :)

(: 23-process-create : )
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $payload := doc("/raw/data/23-payload.xml")
let $result := wrt:process-create($const:xml-options, $payload)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:createResponse/ext:outcome)),
  test:assert-exists(xs:string($result[2]/ext:createResponse/ext:processId)),
  xdmp:document-insert("/test/processId.xml", <test><processId>{xs:string($result[2]/ext:createResponse/ext:processId)}</processId></test>),
  xdmp:log(fn:concat("processId:", xdmp:quote($result[2])))
);

( : 24-process-read : )
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace http = "xdmp:http";

let $pid := xs:string(doc("/test/processId.xml")/test/processId)
let $result := wrt:process-read($const:xml-options, $pid)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/ext:document)
);

( : 25-processsubscription-create : )
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processsubscription";
declare namespace http = "xdmp:http";

let $result := wrt:test-25-processsubscription-create ($const:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('/config/alerts/email-sub-test', xs:string($result[2]/ext:createResponse/ext:subscriptionId))
);

( : 26-processsubscription-read : )
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace alert = "http://marklogic.com/xdmp/alert";
declare namespace ext = "http://marklogic.com/rest-api/resource/processsubscription";
declare namespace http = "xdmp:http";

let $result := wrt:test-26-processsubscription-read ($const:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-equal('/config/alerts/email-sub-test', xs:string($result[2]/ext:readResponse/ext:subscription/alert:config/alert:config-uri))
);

( : 27-document-create : )
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processsubscription";
declare namespace http = "xdmp:http";

let $result := wrt:test-27-document-create ($const:xml-options)
return (
  test:assert-equal('201', xs:string($result[1]/http:code))
);

( : Search needs to be immediately after - it executes too quick otherwise!!! (A blank result may mean processes already finished, not just haven't started) : )
( : 28-processsearch-read : )
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processsearch";
declare namespace http = "xdmp:http";
declare namespace wf = "http://marklogic.com/workflow";

let $result := wrt:test-28-processsearch-read ($const:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:readResponse/ext:outcome)),
  test:assert-exists($result[2]/ext:readResponse/wf:list)
);

( : 29-processasset-create : )
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processasset";
declare namespace http = "xdmp:http";

let $result := wrt:test-29-processasset-create ($const:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:createResponse/ext:outcome)),
  test:assert-equal('/workflowengine/assets/021-initiating-attachment/1/3/RejectedEmail.txt', xs:string($result[2]/ext:createResponse/ext:assetUri))
);

( : 30-processasset-read : )
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace em = "URN:ietf:params:email-xml:";
declare namespace http = "xdmp:http";
declare namespace rf = "URN:ietf:params:rfc822:";

let $result := wrt:test-30-processasset-read ($const:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)) ( :,
  test:assert-equal('Document Rejected', xs:string($result[2]/em:Message/rf:subject)) : )
);

( : 31-processasset-delete : )
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
declare namespace ext = "http://marklogic.com/rest-api/resource/processasset";
declare namespace http = "xdmp:http";

let $result := wrt:test-31-processasset-delete ($const:xml-options)
return (
  test:assert-equal('200', xs:string($result[1]/http:code)),
  test:assert-equal('SUCCESS', xs:string($result[2]/ext:deleteResponse/ext:outcome)),
  test:assert-equal('/workflowengine/assets/021-initiating-attachment/1/3/RejectedEmail.txt', xs:string($result[2]/ext:deleteResponse/ext:assetUri))
);
:)

