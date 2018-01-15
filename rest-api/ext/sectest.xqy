xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/sectest";
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

import module namespace s="http://marklogic.com/sectest" at "/app/models/lib-sectest.xqy";

declare namespace roxy = "http://marklogic.com/roxy";
declare namespace wf="http://marklogic.com/workflow";


(:
 : Call callme() to see if simple privilige assignment is working for the calling user
 :)
declare
%roxy:params("")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"

  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)

  let $out := <ext:response>{s:callme()}</ext:response>

  return
  (
    xdmp:set-response-code(200, "OK"),
    document {
      if ("application/xml" = $preftype) then
        $out
      else
        let $config := json:config("custom")
        let $cx := map:put($config, "text-value", "label" )
        let $cx := map:put($config , "camel-case", fn:true() )
        return
          json:transform-to-json($out, $config)
    }
  )
};


declare
%roxy:params("")
function ext:put(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()? {

    let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"

    let $_ := xdmp:log($params)
    let $_ := xdmp:log($context)

    let $out := <ext:response>{s:cpfme()}</ext:response>

    return
    (
      xdmp:set-response-code(200, "OK"),
      document {
        if ("application/xml" = $preftype) then
          $out
        else
          let $config := json:config("custom")
          let $cx := map:put($config, "text-value", "label" )
          let $cx := map:put($config , "camel-case", fn:true() )
          return
            json:transform-to-json($out, $config)
      }
    )
};
