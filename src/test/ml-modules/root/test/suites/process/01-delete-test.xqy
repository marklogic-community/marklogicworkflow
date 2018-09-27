(:
  This test checks that process deletes occur correctly. Key point is that recursion is required due to potential creation of sub-processes
:)
(: Start by removing any existing processes:)
declare namespace wf="http://marklogic.com/workflow";

/wf:process ! xdmp:document-delete(fn:base-uri(.))
,
xdmp:trace("ml-workflow","in delete-test.xqy")
;
(:
  Create process model for Inclusive Gateway Test 02, and check it has been created correctly
:)
import module namespace test-config = "http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";

import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";

declare namespace model = "http://marklogic.com/rest-api/resource/processmodel";

declare variable $MODEL-INPUT-FILE-NAME := test-constants:file-name-for-model($test-constants:TEST-02-MODEL-NAME);

declare option xdmp:mapping "false";

let $model-response := wrt:processmodel-create ($const:xml-options, $MODEL-INPUT-FILE-NAME)[2]
return
(
  test:assert-equal(xs:string($model-response/model:createResponse/model:outcome/text()),"SUCCESS"),
  test:assert-equal(xs:string($model-response/model:createResponse/model:modelId/text()),test-constants:expected-model-id($test-constants:TEST-02-MODEL-NAME))
)  
;
(:
  Create process for Inclusive Gateway Test 02. Check success. Check pid exists and save.
:)
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace ext = "http://marklogic.com/rest-api/resource/process";

declare variable $PROCESS-MODEL-NAME := test-constants:expected-model-id($test-constants:TEST-02-MODEL-NAME);

let $payload := element ext:createRequest{element ext:processName{$PROCESS-MODEL-NAME},element ext:data{element value1{"A"},element value2{"B"}},element ext:attachments{}}
let $process-response := wrt:process-create($const:xml-options, $payload)[2]
let $pid := $process-response/ext:createResponse/ext:processId/text()
return
(
  test:assert-equal(xs:string($process-response/ext:createResponse/ext:outcome/text()),"SUCCESS"),
  test:assert-exists($pid),
  test-constants:save-pid($pid,$test-constants:TEST-02-MODEL-NAME)
)
;
(: Need to sleep to ensure asynchronous behaviour has completed :)
import module namespace test-config = "http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";

test-config:test-sleep()
;
(:
  There should be three process documents - parent process and two child processes
:)
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace wf="http://marklogic.com/workflow";

test:assert-equal(3,fn:count(/wf:process));

(:
  Delete process
:)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
(:import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";:)
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";

let $test-pid := fn:doc(test-constants:test-pid-uri($test-constants:TEST-02-MODEL-NAME))/test-constants:pid/text()
return
wrt:process-delete($const:xml-options,$test-pid)[0]

;
(:
  There should now be no process documents
:)
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace wf="http://marklogic.com/workflow";

test:assert-equal(0,fn:count(/wf:process))
;
