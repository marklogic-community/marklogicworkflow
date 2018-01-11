xquery version "1.0-ml";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace wf="http://marklogic.com/workflow";
declare namespace prop = "http://marklogic.com/xdmp/property";

let $processUri := "/workflow/processes/fork-simple__1__0/4daff6c3-aba5-4c02-bf38-6cf1bcb8d44c-2018-01-09T16:23:48.244058Z.xml"
let $branch-defs := <wf:branch-definitions xmlns:wf="http://marklogic.com/workflow">
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

let $branch-list := wfu:branch-list($processUri, "whatthefork", $branch-defs)
return (
  test:assert-exists($branch-list)
)

;
(:
import module namespace test="http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
let $_pause := xdmp:sleep(5000)
let $processes := fn:collection("http://marklogic.com/workflow/processes")
return test:assert-equal(3, fn:count($processes))

( : TODO - more tests ! :)



(: 16-process-read : )
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
( : let $_pause := xdmp:sleep(5000) :)

