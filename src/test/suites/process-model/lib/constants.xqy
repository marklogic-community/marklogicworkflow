module namespace test-constants = "http://marklogic.com/workflow/test-constants/process-model";

import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";

declare option xdmp:mapping "false";

declare variable $TEST-MODEL-01-NAME  := "test-model-1";
declare variable $TEST-MODEL-02-NAME  := "test-model-2";
declare variable $TEST-MODEL-03-NAME  := "test-model-3";

(: Useful to single out one :)
declare variable $TEST-MODEL-NAME  := $TEST-MODEL-01-NAME;

declare variable $TEST-MODEL-NAMES := ($TEST-MODEL-01-NAME,$TEST-MODEL-02-NAME,$TEST-MODEL-03-NAME);
declare variable $TEST-FILES := $TEST-MODEL-NAMES ! wth:file-name-for-model(.);

declare variable $UPDATE-MAJOR-VERSION as xs:int := 1;
declare variable $UPDATE-MINOR-VERSION as xs:int := 2;