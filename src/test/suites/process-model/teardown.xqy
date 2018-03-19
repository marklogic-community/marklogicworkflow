import module namespace test-constants = "http://marklogic.com/workflow/test-constants/process-model" at "/test/suites/process-model/lib/constants.xqy";
import module namespace const="http://marklogic.com/roxy/workflow-constants" at "/test/workflow-constants.xqy";
import module namespace wrt="http://marklogic.com/workflow/rest-tests" at "/test/workflow-rest-tests.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";
import module namespace workflow-constants = "http://marklogic.com/workflow/constants" at "/lib/workflow-constants.xqy";

declare namespace ext = "http://marklogic.com/rest-api/resource/process";
declare namespace wf = "http://marklogic.com/workflow";
declare namespace p = "http://marklogic.com/cpf/pipelines";


for $process-model-name in $test-constants:TEST-MODEL-NAMES
return
(
	(: Delete metadata :)
	/wf:process-model-metadata[wf:process-model-name = $test-constants:TEST-MODEL-NAME] ! xdmp:document-delete(fn:base-uri(.)),
	(: Delete model files :)
	cts:uris((),(),cts:collection-query($workflow-constants:MODEL-COLLECTION))[fn:matches(.,wth:file-name-for-model($process-model-name))] ! xdmp:document-delete(.),
	(: Delete associated pipelines :)
	//p:pipeline-name[fn:matches(.,$process-model-name)] ! xdmp:document-delete(fn:base-uri(.))
)	

