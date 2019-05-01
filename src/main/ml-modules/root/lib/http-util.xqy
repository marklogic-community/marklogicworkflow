module namespace http-util = "http://marklogic.com/workflow/http-util";

import module namespace mime-types = "http://marklogic.com/workflow/mime-types" at "/lib/mime-types.xqy";

declare function get-accept-type($context as map:map) as xs:string{
	let $accept-type := map:get($context,"accept-types")
	return
	if($mime-types:HTML = $accept-type) then $mime-types:HTML	
	else if ($mime-types:XML = $accept-type) then $mime-types:XML 
	else $mime-types:JSON 
};

declare function html-response-requested($context as map:map) as xs:boolean{
	$mime-types:HTML = get-accept-type($context)
};	

declare function xml-response-requested($context as map:map) as xs:boolean{
	$mime-types:XML = get-accept-type($context)
};	

declare function json-response-requested($context as map:map) as xs:boolean{
	$mime-types:JSON = get-accept-type($context)
};	
