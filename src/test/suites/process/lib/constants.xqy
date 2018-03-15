module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway";

import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";

declare option xdmp:mapping "false";

declare variable $TEST-02-MODEL-NAME  := "InclusiveGatewayTest-02";
declare variable $TEST-MODEL-NAMES := ($TEST-02-MODEL-NAME);
declare variable $TEST-FILES := $TEST-MODEL-NAMES ! wth:file-name-for-model(.);
