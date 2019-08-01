xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/processengine";

(: import module namespace config = "http://marklogic.com/roxy/config" at "/app/config/config.xqy"; :)
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";
import module namespace wfadmin="http://marklogic.com/workflow-admin" at "/workflowengine/models/workflow-admin.xqy";

import module namespace http-codes = "http://marklogic.com/workflow/http-codes" at "/lib/http-codes.xqy";
import module namespace http-util = "http://marklogic.com/workflow/http-util" at "/lib/http-util.xqy";
import module namespace string-util = "http://marklogic.com/workflow/string-util" at "/lib/string-util.xqy";

declare namespace roxy = "http://marklogic.com/roxy";
declare namespace wf="http://marklogic.com/workflow";


(:
 : Fetch a list of all currently executing processes
 :)
declare
%roxy:params("")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $preftype := http-util:get-accept-type($context)
  let $_ := xdmp:trace("ml-workflow","processenginge-get : requested type = "||$preftype)

  let $_ := map:put($context, "output-types", $preftype)

  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)

  let $processes := wfadmin:processes(())

  let $out :=
      <ext:readResponse><ext:outcome>SUCCESS</ext:outcome>
        {$processes}
      </ext:readResponse>

  return
  (
    map:put($context,"output-status",($http-codes:OK, $http-codes:OK-MESSAGE)),
    document {
      if ( http-util:xml-response-requested($context)) then
      (
        map:put($context, "output-types", "application/xml"),
        $out
      )
      else if( http-util:html-response-requested($context)) then
        ext:xml-to-html( $processes/wf:process-details)
      else
        let $config := json:config("custom")
        let $cx := map:put($config, "text-value", "label" )
        let $cx := map:put($config , "camel-case", fn:true() )
        return
          json:transform-to-json($out, $config)
    }
  )

};

(:
 : Terminate (not delete) all running processes
 :)
declare
function ext:delete(
  $context as map:map,
  $params  as map:map
) as document-node()?
{
  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"

  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)

  let $out :=
      <ext:deleteResponse><ext:outcome>SUCCESS</ext:outcome>
        {wfadmin:terminate( () )}
      </ext:deleteResponse>

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

declare function xml-to-html($objects as element()*)
{
  element html {
    element body {
      element h2 {"Process Engine"},
      element ul {
        for $object in $objects
        let $process-id as xs:string? := $object/@id
        let $process-title as xs:string? := $object/wf:process-data/wf:process/@title
        return
          element li {
            element a { attribute href { "/LATEST/resources/process?rs:processid="||$process-id}, $process-title}
          }
      }
    }
  }
};

