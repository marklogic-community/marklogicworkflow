(:
  This test checks that for an inclusive gateway with two valid downstream routes, we ensure that both tasks on downstream routes are completed before rendezvousing.
:)
(:
  Create process model for Inclusive Gateway Test 02, and check it has been created correctly
:)
import module namespace test-config = "http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = "http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";

import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";

declare namespace model = "http://marklogic.com/rest-api/resource/processmodel";

declare variable $MODEL-INPUT-FILE-NAME := test-constants:file-name-for-model($test-constants:TEST-02-MODEL-NAME);

declare option xdmp:mapping "false";

let $model-response := wrt:processmodel-create ($const:xml-options, $MODEL-INPUT-FILE-NAME)[2]
return
(
  test:assert-equal("SUCCESS", xs:string($model-response/model:createResponse/model:outcome/text())),
  test:assert-equal(test-constants:expected-model-id($test-constants:TEST-02-MODEL-NAME), xs:string($model-response/model:createResponse/model:modelId/text()))
)
;
(:
  Create process for Inclusive Gateway Test 02. Check success. Check pid exists and save.
:)
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace test = "http://marklogic.com/test" at "/test/test-helper.xqy";

declare namespace ext = "http://marklogic.com/rest-api/resource/process";

declare variable $PROCESS-MODEL-NAME := test-constants:expected-model-id($test-constants:TEST-02-MODEL-NAME);

let $payload := element ext:createRequest{element ext:processName{$PROCESS-MODEL-NAME},element ext:data{element value1{"A"},element value2{"B"}},element ext:attachments{}}
let $process-response := wrt:process-create($const:xml-options, $payload)[2]
let $pid := $process-response/ext:createResponse/ext:processId/text()
return
(
  test:assert-equal("SUCCESS", xs:string($process-response/ext:createResponse/ext:outcome/text())),
  test:assert-exists($pid),
  test-constants:save-pid($pid,$test-constants:TEST-02-MODEL-NAME)
)
;
(: Need to sleep to ensure asynchronous behaviour has completed :)
xdmp:sleep(10000)
;
(:
  Check process has entered the first gateway ( and effectively stopped there )
:)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test = "http://marklogic.com/test" at "/test/test-helper.xqy";

declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace wf = "http://marklogic.com/workflow";

let $test-pid := fn:doc(test-constants:test-pid-uri($test-constants:TEST-02-MODEL-NAME))/test-constants:pid/text()
let $process-state := wrt:process-read($const:xml-options,$test-pid)[2]/ext:readResponse
let $current-state := ($process-state/ext:document/wf:process/wf:audit-trail/wf:audit)[fn:last()]/wf:state/text()
return
(
  test:assert-equal("SUCCESS", xs:string($process-state/ext:outcome/text())),
  test:assert-equal("InclusiveGateway_1", fn:tokenize($current-state,"/")[fn:last()])
);
(:
  Fork has not rendezvoused because there are user tasks requiring completion. We complete the first one.
:)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test = "http://marklogic.com/test" at "/test/test-helper.xqy";

declare namespace wf = "http://marklogic.com/workflow";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";

let $test-pid := fn:doc(test-constants:test-pid-uri($test-constants:TEST-02-MODEL-NAME))/test-constants:pid/text()
let $test-pid := fn:substring-before($test-pid, "+") (: some platforms not handling timezone well :)
let $child-pid := (/wf:process[fn:matches(wf:parent,$test-pid)]/@id/fn:string())[1]
let $update-response := wrt:call-complete-on-pid($const:xml-options,$child-pid)/ext:updateResponse
return
  test:assert-equal("SUCCESS", xs:string($update-response/ext:outcome/text()))
;
(: Need to sleep to ensure asynchronous behaviour has completed :)
import module namespace test-config = "http://marklogic.com/test-config" at "/test/test-config.xqy";

test-config:test-sleep()
;
(:
  Check process is still in the waiting state
:)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test = "http://marklogic.com/test" at "/test/test-helper.xqy";

declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace wf = "http://marklogic.com/workflow";

let $test-pid := fn:doc(test-constants:test-pid-uri($test-constants:TEST-02-MODEL-NAME))/test-constants:pid/text()
let $process-state := wrt:process-read($const:xml-options,$test-pid)[2]/ext:readResponse
let $penultimate-state := ($process-state/ext:document/wf:process/wf:audit-trail/wf:audit)[fn:last() -1]/wf:state/text()
let $current-state := ($process-state/ext:document/wf:process/wf:audit-trail/wf:audit)[fn:last()]/wf:state/text()
return
(
  test:assert-equal("SUCCESS", xs:string($process-state/ext:outcome/text())),
  test:assert-equal("InclusiveGateway_1",fn:tokenize($current-state,"/")[fn:last()])
)
;
(:
  Fork has not rendezvoused because there are user tasks requiring completion. We complete the second one.
:)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test = "http://marklogic.com/test" at "/test/test-helper.xqy";

declare namespace wf = "http://marklogic.com/workflow";
declare namespace ext = "http://marklogic.com/rest-api/resource/process";

let $test-pid := fn:doc(test-constants:test-pid-uri($test-constants:TEST-02-MODEL-NAME))/test-constants:pid/text()
let $test-pid := fn:substring-before($test-pid, "+") (: some platforms not handling timezone well :)
let $child-pid := (/wf:process[fn:matches(wf:parent,$test-pid)]/@id/fn:string())[2]
let $update-response := wrt:call-complete-on-pid($const:xml-options,$child-pid)/ext:updateResponse
return
  test:assert-equal("SUCCESS", xs:string($update-response/ext:outcome/text()))
;
(: Need to sleep to ensure asynchronous behaviour has completed :)
import module namespace test-config = "http://marklogic.com/test-config" at "/test/test-config.xqy";

test-config:test-sleep()
;
(:
  Check process has rendezvoused and completed
:)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace const="http://marklogic.com/test/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test = "http://marklogic.com/test" at "/test/test-helper.xqy";

declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace wf = "http://marklogic.com/workflow";

let $test-pid := fn:doc(test-constants:test-pid-uri($test-constants:TEST-02-MODEL-NAME))/test-constants:pid/text()
let $process-state := wrt:process-read($const:xml-options,$test-pid)[2]/ext:readResponse
let $penultimate-state := ($process-state/ext:document/wf:process/wf:audit-trail/wf:audit)[fn:last() -1]/wf:state/text()
let $current-state := ($process-state/ext:document/wf:process/wf:audit-trail/wf:audit)[fn:last()]/wf:state/text()
return
(
  test:assert-equal("SUCCESS", xs:string($process-state/ext:outcome/text())),
  test:assert-equal("EndEvent_1",fn:tokenize($current-state,"/")[fn:last()]),
  test:assert-equal("InclusiveGateway_1__rv",fn:tokenize($penultimate-state,"/")[fn:last()])
)
;
