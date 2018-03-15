(:
	Checks on process model metadata
:)
(:
  Create process model and check it has been created correctly
:)
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/process-model/lib/constants.xqy";
import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";

declare namespace model = "http://marklogic.com/rest-api/resource/processmodel";

declare variable $MODEL-INPUT-FILE-NAME := wth:file-name-for-model($test-constants:TEST-MODEL-NAME);

declare option xdmp:mapping "false";

let $model-response := wrt:processmodel-create ($const:xml-options, $MODEL-INPUT-FILE-NAME)[2]
return
(
  test:assert-equal(xs:string($model-response/model:createResponse/model:outcome/text()),"SUCCESS"),
  test:assert-equal(xs:string($model-response/model:createResponse/model:modelId/text()),wth:expected-model-id($test-constants:TEST-MODEL-NAME))
)  
;
(:
  Check metadata
:)

import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/process-model/lib/constants.xqy";
import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace wfi="http://marklogic.com/workflow-import" at "/workflowengine/models/workflow-import.xqy";

declare namespace wf="http://marklogic.com/workflow";


let $metadata := /wf:process-model-metadata[wf:process-model-name = $test-constants:TEST-MODEL-NAME]
return
(
  test:assert-exists($metadata),
  test:assert-equal($metadata/wf:major-version/fn:string(),"1"),
  test:assert-equal($metadata/wf:minor-version/fn:string(),"0"),
  test:assert-equal($metadata/wf:process-model-full-name/fn:string(),wfi:process-model-full-name($test-constants:TEST-MODEL-NAME,"1","0"))
)  
;
(:
  Now do an update
:)
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/process-model/lib/constants.xqy";
import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace wfi="http://marklogic.com/workflow-import" at "/workflowengine/models/workflow-import.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";

declare namespace model = "http://marklogic.com/rest-api/resource/processmodel";

declare variable $MODEL-INPUT-FILE-NAME := wth:file-name-for-model($test-constants:TEST-MODEL-NAME);

declare option xdmp:mapping "false";

let $model-response := wrt:processmodel-create ($const:xml-options, $MODEL-INPUT-FILE-NAME,$test-constants:UPDATE-MAJOR-VERSION,$test-constants:UPDATE-MINOR-VERSION)[2]
let $expected-model-full-name := wfi:process-model-full-name($test-constants:TEST-MODEL-NAME,xs:string($test-constants:UPDATE-MAJOR-VERSION),xs:string($test-constants:UPDATE-MINOR-VERSION))
return
(
  test:assert-equal(xs:string($model-response/model:createResponse/model:outcome/text()),"SUCCESS"),
  test:assert-equal(xs:string($model-response/model:createResponse/model:modelId/text()),$expected-model-full-name)
  
)  
;
(:
  Check metadata
:)

import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/process-model/lib/constants.xqy";
import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace wfi="http://marklogic.com/workflow-import" at "/workflowengine/models/workflow-import.xqy";

declare namespace wf="http://marklogic.com/workflow";

let $expected-model-full-name := wfi:process-model-full-name($test-constants:TEST-MODEL-NAME,xs:string($test-constants:UPDATE-MAJOR-VERSION),xs:string($test-constants:UPDATE-MINOR-VERSION))
let $metadata := /wf:process-model-metadata[wf:process-model-full-name = $expected-model-full-name]
return
(
  test:assert-exists($metadata),
  test:assert-equal($metadata/wf:major-version/fn:string(),xs:string($test-constants:UPDATE-MAJOR-VERSION)),
  test:assert-equal($metadata/wf:minor-version/fn:string(),xs:string($test-constants:UPDATE-MINOR-VERSION)),
  test:assert-equal($metadata/wf:process-model-name/fn:string(),$test-constants:TEST-MODEL-NAME)
)  
;

