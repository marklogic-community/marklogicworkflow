xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/processasset";

import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";
import module namespace wfi="http://marklogic.com/workflow-import" at "/workflowengine/models/workflow-import.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";

declare namespace wf="http://marklogic.com/workflow";
declare namespace roxy = "http://marklogic.com/roxy";
declare namespace rapi = "http://marklogic.com/rest-api";


(:
 : Get the process asset by exact name and version. Will return top level default if no versioned asset exists.
 :  ?model=name[&asset=name[&major=numeric[&minor=numeric]]]
 :  E.g. ?model=021-initiating-attachment&asset=RejectedEmail.txt&majorversion=1&minorversion=0
 :  N.B. If no asset name is specified, lists all the assets available for process model
 :)
declare
%roxy:params("")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  (
    let $assets := wfu:getProcessAssets(map:get($params,"asset"),map:get($params,"model"),
      map:get($params,"major"),map:get($params,"minor"))

    return (
      (: TODO replace the below with multi part mime support, as required, in case of multiple results :)

      xdmp:set-response-code(200, "OK"),
      (: TODO get mime type of the assets from its URI, and return in the response :)

      document {
        $assets[1]

      }
    )
  )
};


(:
 : Update the process asset
 :  ?model=name[&asset=name[&major=numeric[&minor=numeric]]]
 :)
declare
%roxy:params("")
%rapi:transaction-mode("update")
function ext:put(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()?
{

    let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else
      if ("text/plain" = map:get($context,"accept-types")) then "text/plain" else "application/json"

    let $_ := xdmp:log($input)

    let $res := wfu:setProcessAsset(map:get($params,"asset"), $input, map:get($params,"model"),
      map:get($params,"major"),map:get($params,"minor"))

    let $out := <ext:createResponse><ext:outcome>SUCCESS</ext:outcome><ext:assetUri>{$res}</ext:assetUri></ext:createResponse>

    return
    (
      map:put($context, "output-types", $preftype),
      xdmp:set-response-code(200, "OK"),
      document {
        if ("application/xml" = $preftype) then
          $out
        else if ("text/plain" = $preftype) then
          $res
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
 : Delete the process asset
 :  ?model=name[&asset=name[&major=numeric[&minor=numeric]]]
 :)
declare
%roxy:params("")
function ext:delete(
    $context as map:map,
    $params  as map:map
) as document-node()?
{

    let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else
      if ("text/plain" = map:get($context,"accept-types")) then "text/plain" else "application/json"

    let $res := wfu:deleteProcessAsset(map:get($params,"asset"), map:get($params,"model"),
      map:get($params,"major"),map:get($params,"minor"))

    let $out := <ext:deleteResponse><ext:outcome>SUCCESS</ext:outcome><ext:assetUri>{$res}</ext:assetUri></ext:deleteResponse>

    return
    (
      map:put($context, "output-types", $preftype),
      xdmp:set-response-code(200, "OK"),
      document {
        if ("application/xml" = $preftype) then
          $out
        else if ("text/plain" = $preftype) then
          $res
        else
          let $config := json:config("custom")
          let $cx := map:put($config, "text-value", "label" )
          let $cx := map:put($config , "camel-case", fn:true() )
          return
            json:transform-to-json($out, $config)
      }
    )
};
