
xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/processsubscription";

(: import module namespace config = "http://marklogic.com/roxy/config" at "/app/config/config.xqy"; :)
import module namespace json6 = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/app/models/workflow-util.xqy";

declare namespace roxy = "http://marklogic.com/roxy";
declare namespace wf="http://marklogic.com/workflow";

(:
 : Create a process subscription (saved content alert)
 :)
declare
%roxy:params("")
function ext:put(
   $context as map:map,
   $params  as map:map,
   $input   as document-node()*
) as document-node()? {

 let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"

 let $_ := xdmp:log($input)

 let $res := wfu:createSubscription($input/ext:createRequest/ext:processName/text(),
   $input/ext:createRequest/ext:name/text(),$input/ext:createRequest/ext:query/element())

 let $out := <ext:createResponse><ext:outcome>SUCCESS</ext:outcome><ext:subscriptionId>{$res}</ext:subscriptionId></ext:createResponse>

 return
 (
   map:put($context, "output-types", $preftype),
   xdmp:set-response-code(200, "OK"),
   document {
     if ("application/xml" = $preftype) then
       $out
     else
       "{TODO:'TODO'}"
   }
 )
};
