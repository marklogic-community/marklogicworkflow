xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/tuplesext";
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

declare namespace roxy = "http://marklogic.com/roxy";


(:
 : Apply query and return results
 :)
declare
%roxy:params("")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $preftype :=
    if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else
    if ("text/plain" = map:get($context,"accept-types")) then "text/plain" else "application/json"
  let $out :=
    <values-response>
      <aggregate-result>
        <name>ageavg</name><_value>25</_value>
      </aggregate-result>
      <aggregate-result>
        <name>agesum</name><_value>25000</_value>
      </aggregate-result>
    </values-response>

  return
  (
    map:put($context, "output-types", $preftype),
    xdmp:set-response-code(200, "OK"),
    document {
      if ("application/xml" = $preftype) then
        $out
      else
        let $config := json:config("custom")
        let $cx := map:put($config, "text-value", "label" )
        let $cx := map:put($config , "camel-case", fn:false() )
        return
          json:transform-to-json($out, $config)
    }
  )
};
