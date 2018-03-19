module namespace wth = "http://marklogic.com/roxy/workflow-test-helper";

declare namespace http = "xdmp:http";

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


declare function rest-uri($host as xs:string,$port as xs:int,$endpoint as xs:string) as xs:string{
  fn:concat("http://",$host,":",$port,$endpoint)
};

declare function http-options($content-type as xs:string,$user-name as xs:string,$password as xs:string) as element(http:options){
  <options xmlns="xdmp:http">
    <authentication method="digest">
      <username>{$user-name}</username>
      <password>{$password}</password>
    </authentication>
    <headers>
      <accept>{$content-type}</accept>
    </headers>                
  </options>
};

