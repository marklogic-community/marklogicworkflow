(:
  In this test we check that we can successfully delete a subscription

  Prep) Set up process model

  1) Set up the subscription to the model
  2) Check the subscription exists using the API
  3) Verify that we have alert documents and a domain - white box testing
  4) Delete the subscription using the API and check the response
  5) Verify that we have NO alert documents and NO domain - white box testing

:)
import module namespace test-config = "http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";

declare namespace model = "http://marklogic.com/rest-api/resource/processmodel";

declare variable $MODEL-INPUT-FILE-NAME := wth:file-name-for-model($test-constants:TEST-02-MODEL-NAME);

declare option xdmp:mapping "false";

let $model-response := wrt:processmodel-create ($const:xml-options, $MODEL-INPUT-FILE-NAME)[2]
return
(
  test:assert-equal(xs:string($model-response/model:createResponse/model:outcome/text()),"SUCCESS"),
  test:assert-equal(xs:string($model-response/model:createResponse/model:modelId/text()),wth:expected-model-id($test-constants:TEST-02-MODEL-NAME))
)  
;

import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/process-subscription/lib/constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";

declare namespace ext="http://marklogic.com/rest-api/resource/processsubscription";

let $test-payload := 
<ext:createRequest xmlns:ext="http://marklogic.com/rest-api/resource/processsubscription">
  <ext:processName>{wth:expected-model-id($test-constants:TEST-02-MODEL-NAME)}</ext:processName>
  <ext:name>{$test-constants:SUBSCRIPTION-NAME}</ext:name>  
  <ext:domain>
   <ext:name>{$test-constants:DOMAIN-NAME}</ext:name>
   <ext:type>directory</ext:type>
   <ext:path>{$test-constants:MONITORED-DIRECTORY}</ext:path>
   <ext:depth>0</ext:depth>
  </ext:domain>
  <ext:query>
    <cts:and-query xmlns:cts="http://marklogic.com/cts"></cts:and-query>
  </ext:query>
</ext:createRequest>
let $create-response := wrt:test-processsubscription-create($const:xml-options,$test-payload)[2]
return
(
  test:assert-equal($create-response/ext:createResponse/ext:subscriptionId/fn:string(),test-constants:expected-subscription-id($test-constants:SUBSCRIPTION-NAME)),
  test:assert-equal($create-response/ext:createResponse/ext:outcome/fn:string(),"SUCCESS")
)  
;
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/process-subscription/lib/constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace alert="http://marklogic.com/xdmp/alert";
declare namespace ext="http://marklogic.com/rest-api/resource/processsubscription";

let $read-response := wrt:test-processsubscription-read($const:xml-options,$test-constants:SUBSCRIPTION-NAME)
return
(
  test:assert-equal($read-response/ext:readResponse/ext:subscription/alert:config/alert:config-uri/fn:string(),test-constants:expected-subscription-id($test-constants:SUBSCRIPTION-NAME)),
  test:assert-equal($read-response/ext:readResponse/ext:outcome/fn:string(),"SUCCESS")
)  
;
(: Internally verify that we have a cpf domain with the expected name :)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/process-subscription/lib/constants.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace dom  = "http://marklogic.com/cpf/domains";

test:assert-true(
xdmp:invoke-function(function(){
  fn:exists(//dom:domain-name/text()[fn:matches(.,$test-constants:DOMAIN-NAME)])},<options xmlns="xdmp:eval"><database>{xdmp:triggers-database()}</database></options>))
;
(: And that we have three alert documents  :)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/process-subscription/lib/constants.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

test:assert-equal(fn:count(fn:collection(test-constants:expected-subscription-id($test-constants:SUBSCRIPTION-NAME))),3)
;
(: Delete should return a 204 :)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/process-subscription/lib/constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace http = "xdmp:http";

let $delete-response := wrt:test-processsubscription-delete($const:xml-options,$test-constants:SUBSCRIPTION-NAME)
return
test:assert-equal($delete-response/http:code/fn:data(),204)
;
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/process-subscription/lib/constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace alert="http://marklogic.com/xdmp/alert";
declare namespace ext="http://marklogic.com/rest-api/resource/processsubscription";

let $read-response := wrt:test-processsubscription-read($const:xml-options,$test-constants:SUBSCRIPTION-NAME)
return
test:assert-equal($read-response/ext:readResponse/ext:outcome/fn:string(),"NOT FOUND")
;
(: Internally verify that we NO LONGER have a cpf domain with the expected name :)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/process-subscription/lib/constants.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

declare namespace dom  = "http://marklogic.com/cpf/domains";

test:assert-false(
xdmp:invoke-function(function(){
  fn:exists(//dom:domain-name/text()[fn:matches(.,$test-constants:DOMAIN-NAME)])},<options xmlns="xdmp:eval"><database>{xdmp:triggers-database()}</database></options>))
;
(: And that we have NO alert documents  :)
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/process-subscription/lib/constants.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

test:assert-equal(fn:count(fn:collection(test-constants:expected-subscription-id($test-constants:SUBSCRIPTION-NAME))),0)
