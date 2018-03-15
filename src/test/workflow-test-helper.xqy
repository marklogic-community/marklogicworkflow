module namespace wth = "http://marklogic.com/roxy/workflow-test-helper";

declare option xdmp:mapping "false";

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
	let $pid-content := element wth:pid{$pid}
	return
	xdmp:document-insert(test-pid-uri($model-name),$pid-content)
};

