import module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway" at "lib/constants.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";

declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace wf = "http://marklogic.com/workflow";
declare namespace p = "http://marklogic.com/cpf/pipelines";


for $process-model-name in $test-constants:TEST-MODEL-NAMES
return
(
	(: Delete model files :)
	cts:uris()[fn:matches(.,wth:file-name-for-model($process-model-name))] ! xdmp:document-delete(.),
	(: Delete associated pipelines :)
	//p:pipeline-name[fn:matches(.,$process-model-name)] ! xdmp:document-delete(fn:base-uri(.))
)	