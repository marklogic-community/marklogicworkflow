module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway";

import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";

declare option xdmp:mapping "false";

declare variable $TEST-MODEL-NAME  := "test-model";
declare variable $TEST-MODEL-NAMES := ($TEST-MODEL-NAME);
declare variable $TEST-FILES := $TEST-MODEL-NAMES ! wth:file-name-for-model(.);
declare variable $DOMAIN-NAME := "process-subscription-test-domain";
declare variable $SUBSCRIPTION-NAME := "process-subscription-test-subscription";
declare variable $MONITORED-DIRECTORY := "/test/process-subscription/monitored-directory/";

declare function expected-subscription-id($subscription-name as xs:string) as xs:string{"/config/alerts/"||$subscription-name};
