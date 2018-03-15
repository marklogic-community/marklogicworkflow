xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/processmodel";

import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";
import module namespace wfi="http://marklogic.com/workflow-import" at "/workflowengine/models/workflow-import.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";
import module namespace http-codes = "http://marklogic.com/workflow/http-codes" at "/lib/http-codes.xqy";
import module namespace mime-types = "http://marklogic.com/workflow/mime-types" at "/lib/mime-types.xqy";

declare namespace wf="http://marklogic.com/workflow";
declare namespace rapi= "http://marklogic.com/rest-api";
declare namespace roxy = "http://marklogic.com/roxy";

(:
 : Get the process model by exact name
 :  ?publishedId=name
 :)
declare
%roxy:params("")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $preftype := if ($mime-types:XML = map:get($context,"accept-types")) then $mime-types:XML else $mime-types:JSON 
  let $_ := xdmp:trace("ml-workflow","processmodel-get : requested type = "||$preftype)
  let $model := wfi:get-model-by-name(map:get($params,"publishedId"))
  return
  (
    map:put($context,"output-status",($http-codes:OK, $http-codes:OK-MESSAGE)),
    map:put($context, "output-types", $preftype),
    document{
      if ($mime-types:XML = $preftype) then
        $model
      else
        convert-to-json($model)
    }
  )
};


(:
 : Publish the process model
 :  ?[major=numeric[&minor=numeric]]&name=name[&enable=true]
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
  let $preftype := if ($mime-types:XML = map:get($context,"accept-types")) then $mime-types:XML else $mime-types:JSON


  let $_ := xdmp:log("processmodel: PUT: name: " || map:get($params,"name") || ", major: " || map:get($params,"major") || ", minor: " || map:get($params,"minor"))
  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)
  let $_ := xdmp:log($input)

  let $enable := if (map:get($params,"enable") = "true") then fn:true() else fn:false()
  let $_ := xdmp:log("Enabled? : " || xs:string($enable))

  let $input := xdmp:unquote(xdmp:quote($input))
  let $modelid := wfi:install-and-convert($input,map:get($params,"name"),(map:get($params,"major"),"1")[1],(map:get($params,"minor"),"0")[1], $enable )

  let $response := <ext:createResponse><ext:outcome>SUCCESS</ext:outcome><ext:modelId>{$modelid}</ext:modelId></ext:createResponse>

  return
  (
    map:put($context,"output-status",($http-codes:OK, $http-codes:OK-MESSAGE)),
    map:put($context, "output-types", $preftype),
    document{
      (: 1. Take the process model document and convert to a CPF pipeline document :)
      (: 2. Add a CPF pipeline by using a directory scope of /cpf/processes/ (<PROCURI>/<UUID.xml>) depth infinite :)
      (: 3. Optionally enable :)
      if ($mime-types:XML = $preftype) then
        $response
      else
        convert-to-json($response)
    }

  )
};




(:
 : Add a new process model version.
 : ?publishedId=myprocess__1__0
 :)
declare
%roxy:params("")
%rapi:transaction-mode("update")
function ext:post(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()*
{
  let $preftype := if ($mime-types:XML = map:get($context,"accept-types")) then $mime-types:XML else $mime-types:JSON

  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)
  let $_ := xdmp:log($input)

  let $published := xs:string(wfi:enable(map:get($params,"publishedId")))

  let $response := <ext:updateResponse><ext:outcome>SUCCESS</ext:outcome><ext:domainId>{$published}</ext:domainId></ext:updateResponse>

  return
  (

    map:put($context,"output-status",($http-codes:OK, $http-codes:OK-MESSAGE)),
    map:put($context, "output-types", $preftype),    
    document {
      if ($mime-types:XML = $preftype) then
        $response
      else
        convert-to-json($response)
  }

  )
};


declare private function convert-to-json($response as element()?) as object-node()?{
  let $config := json:config("custom")
  let $cx := map:put($config, "text-value", "label" )
  let $cx := map:put($config , "camel-case", fn:true() )
  return
  json:transform-to-json($response, $config)
};  

(:)
(:
 : Remove the specified process model from execution
 :  ?[major=numeric[&minor=numeric]]&modelid=modelid
 :)
declare function ext:delete(
    $context as map:map,
    $params  as map:map
) as document-node()?
{
  let $preftype := if ($mime-types:XML = map:get($context,"accept-types")) then $mime-types:XML else $mime-types:JSON

  let $name := map:get($params,"something")
  let $l := xdmp:log("DELETE /v1/resources/processmodel CALLED")
  let $response := ()
  let $l := xdmp:log($params)
  let $l := xdmp:log($context)
  return (
    map:put($context,"output-status",($http-codes:OK, $http-codes:OK-MESSAGE)),
    map:put($context, "output-types", $preftype),        
    document {

            if ($mime-types:XML = $preftype) then
              $response
            else
              let $config := json:config("custom")
              let $cx := map:put($config, "text-value", "label" )
              let $cx := map:put($config , "camel-case", fn:true() )
              return
                json:transform-to-json($response, $config)


   })
};
:)
