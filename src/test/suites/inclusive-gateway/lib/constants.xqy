module namespace test-constants = "http://marklogic.com/workflow/test-constants/inclusive-gateway";

import module namespace wth = "http://marklogic.com/roxy/workflow-test-helper" at "/test/workflow-test-helper.xqy";

declare option xdmp:mapping "false";

declare variable $TEST-01-MODEL-NAME  := "InclusiveGatewayTest-01";
declare variable $TEST-02-MODEL-NAME  := "InclusiveGatewayTest-02";
declare variable $TEST-MODEL-NAMES := ($TEST-01-MODEL-NAME,$TEST-02-MODEL-NAME);
declare variable $TEST-FILES := $TEST-MODEL-NAMES ! file-name-for-model(.);
declare variable $TEST-PID-DIR := "/test/pid/";

declare function file-name-for-model($model-name as xs:string){
	$model-name||".bpmn"
};

declare function expected-model-id($model-name) as xs:string{
	$model-name||"__1__0"
};

declare function test-pid-uri($model-name as xs:string) as xs:string{
	$TEST-PID-DIR||$model-name||".xml"
};

declare function save-pid($pid,$model-name){
	let $pid-content := element test-constants:pid{$pid}
	return
	  xdmp:document-insert(test-pid-uri($model-name),$pid-content)
};


