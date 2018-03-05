(:
  This test checks that for an inclusive gateway with two downstream routes, only one of which is activated, 
  rendezvousing is conditional only on the activated task being completed.
:)  
(:
  Create process model for Inclusive Gateway Test 01, and check it has been created correctly
:)
import module namespace test-config = "http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";

import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";

declare namespace model = "http://marklogic.com/rest-api/resource/processmodel";

declare variable $MODEL-INPUT-FILE-NAME := test-constants:file-name-for-model($test-constants:TEST-01-MODEL-NAME);

declare option xdmp:mapping "false";

let $model-response := wrt:processmodel-create ($const:xml-options, $MODEL-INPUT-FILE-NAME)[2]
return
(
  test:assert-equal(xs:string($model-response/model:createResponse/model:outcome/text()),"SUCCESS"),
  test:assert-equal(xs:string($model-response/model:createResponse/model:modelId/text()),test-constants:expected-model-id($test-constants:TEST-01-MODEL-NAME))
)  
;
(:
  Create process for Inclusive Gateway Test 01. Check success. Check pid exists and save.
:)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace ext = "http://marklogic.com/rest-api/resource/process";

declare variable $PROCESS-MODEL-NAME := test-constants:expected-model-id($test-constants:TEST-01-MODEL-NAME);

let $payload := element ext:createRequest{element ext:processName{$PROCESS-MODEL-NAME},element ext:data{element value{"A"}},element ext:attachments{}}
let $process-response := wrt:process-create($const:xml-options, $payload)[2]
let $pid := $process-response/ext:createResponse/ext:processId/text()
return
(
  test:assert-equal(xs:string($process-response/ext:createResponse/ext:outcome/text()),"SUCCESS"),
  test:assert-exists($pid),
  test-constants:save-pid($pid,$test-constants:TEST-01-MODEL-NAME)
)
;
(: Need to sleep to ensure asynchronous behaviour has completed :)
xdmp:sleep(2000)
;
(:
  Check process has entered the first gateway ( and effectively stopped there )
:)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace wf = "http://marklogic.com/workflow";

let $test-pid := fn:doc(test-constants:test-pid-uri($test-constants:TEST-01-MODEL-NAME))/test-constants:pid/text()
let $process-state := wrt:process-read($const:xml-options,$test-pid)[2]/ext:readResponse
let $current-state := ($process-state/ext:document/wf:process/wf:audit-trail/wf:audit)[fn:last()]/wf:state/text()
return
(
test:assert-equal(xs:string($process-state/ext:outcome/text()),"SUCCESS"),
test:assert-equal("InclusiveGateway_1",fn:tokenize($current-state,"/")[fn:last()])
)
;
(:
  Fork has not rendezvoused because there is a user task requiring completion. We therefore complete it
:)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace wf = "http://marklogic.com/workflow";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";

let $test-pid := fn:doc(test-constants:test-pid-uri($test-constants:TEST-01-MODEL-NAME))/test-constants:pid/text()
let $child-pid := /wf:process[fn:matches(wf:parent,$test-pid)]/@id/fn:string()
let $update-response := wrt:call-complete-on-pid($const:xml-options,$child-pid)/ext:updateResponse
return
test:assert-equal(xs:string($update-response/ext:outcome/text()),"SUCCESS")
;
(: Need to sleep to ensure asynchronous behaviour has completed :)
xdmp:sleep(2000)
;
(:
  Check process has rendezvoused and completed
:)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace wf = "http://marklogic.com/workflow";

let $test-pid := fn:doc(test-constants:test-pid-uri($test-constants:TEST-01-MODEL-NAME))/test-constants:pid/text()
let $process-state := wrt:process-read($const:xml-options,$test-pid)[2]/ext:readResponse
let $penultimate-state := ($process-state/ext:document/wf:process/wf:audit-trail/wf:audit)[fn:last() -1]/wf:state/text()
let $current-state := ($process-state/ext:document/wf:process/wf:audit-trail/wf:audit)[fn:last()]/wf:state/text()
return
(
test:assert-equal(xs:string($process-state/ext:outcome/text()),"SUCCESS"),
test:assert-equal("EndEvent_1",fn:tokenize($current-state,"/")[fn:last()]),
test:assert-equal("InclusiveGateway_1__rv",fn:tokenize($penultimate-state,"/")[fn:last()])
)

