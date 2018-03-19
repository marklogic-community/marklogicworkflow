import module namespace test-constants = "http://marklogic.com/workflow/test-constants/process-model" at "/test/suites/process-model/lib/constants.xqy";
import module namespace test-config = "http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";

for $test-file in $test-constants:TEST-FILES
let $target-uri := test-config:local-uri-for-test-file($test-file)
return
if(fn:exists(fn:doc($target-uri))) then xdmp:document-delete($target-uri) else()