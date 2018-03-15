xquery version "1.0-ml";

import module namespace test-config = "http://marklogic.com/roxy/test-config" at "/test/test-config.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "/test/suites/inclusive-gateway/lib/constants.xqy";
import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";
	
for $test-file in $test-constants:TEST-FILES
let $target-uri := test-config:local-uri-for-test-file($test-file)
return
test:load-test-file($test-file, xdmp:database(), $target-uri)
