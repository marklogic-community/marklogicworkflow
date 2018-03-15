module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway";

import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";

declare option xdmp:mapping "false";

declare variable $TEST-MODEL-NAME  := "test-model";
declare variable $TEST-MODEL-NAMES := ($TEST-MODEL-NAME);
declare variable $TEST-FILES := $TEST-MODEL-NAMES ! wth:file-name-for-model(.);

declare variable $UPDATE-MAJOR-VERSION as xs:int := 1;
declare variable $UPDATE-MINOR-VERSION as xs:int := 2;