xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/processmodel";

import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";
import module namespace wfi="http://marklogic.com/workflow-import" at "/workflowengine/models/workflow-import.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";
import module namespace http-codes = "http://marklogic.com/workflow/http-codes" at "/lib/http-codes.xqy";
import module namespace http-util = "http://marklogic.com/workflow/http-util" at "/lib/http-util.xqy";
import module namespace string-util = "http://marklogic.com/workflow/string-util" at "/lib/string-util.xqy";

declare namespace wf="http://marklogic.com/workflow";
declare namespace rapi= "http://marklogic.com/rest-api";
declare namespace roxy = "http://marklogic.com/roxy";

declare option xdmp:output "omit-xml-declaration = yes";
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
  let $preftype := http-util:get-accept-type($context)
  let $_ := xdmp:trace("ml-workflow","processmodel-get : requested type = "||$preftype)
  let $output := 
  if((map:get($params,"publishedId"))) then
    wfi:get-model-by-name(map:get($params,"publishedId"))
  else if(map:get($params,"name")) then
    process-model-response(map:get($params,"name"))
  else
    process-model-list()      
  return
  (
    map:put($context,"output-status",($http-codes:OK, $http-codes:OK-MESSAGE)),
    map:put($context, "output-types", $preftype),
    document{
      if(http-util:xml-response-requested($context)) then
        $output
      else if(http-util:html-response-requested($context)) then
        xml-to-html($output)
      else
        convert-to-json($output)
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
  let $preftype := http-util:get-accept-type($context)
  let $enable := if (map:get($params,"enable") = "true") then fn:true() else fn:false()

  let $_ := xdmp:log("processmodel: PUT: name: " || map:get($params,"name") || ", major: " || map:get($params,"major") || ", minor: " || map:get($params,"minor"))
  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)
  let $_ := xdmp:log($input)
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
      if(http-util:xml-response-requested($context)) then
        $response
      else if(http-util:html-response-requested($context)) then
        xml-to-html($response)
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
  let $preftype := http-util:get-accept-type($context)

  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)
  let $_ := xdmp:log($input)

  let $published := xs:string(wfi:enable(map:get($params,"publishedId")))
  let $response := <ext:updateResponse><ext:outcome>SUCCESS</ext:outcome><ext:domainId>{$published}</ext:domainId></ext:updateResponse>
  return
  (
    map:put($context,"output-status",($http-codes:OK, $http-codes:OK-MESSAGE)),
    map:put($context, "output-types", $preftype),    
    document{
      if(http-util:xml-response-requested($context)) then
        $response
      else if(http-util:html-response-requested($context)) then
        xml-to-html($response)
      else
        convert-to-json($response)
    }
  )
};

(:
  $response could be a document node or an element - so use type node
:)
declare private function convert-to-json($response as node()?) as object-node()?{
  let $config := json:config("custom")
  let $cx := map:put($config, "text-value", "label")
  let $cx := map:put($config ,"camel-case", fn:true())
  let $cx := map:put($config,"array-element-names",xs:QName("wf:process-model"))
  return
  json:transform-to-json($response, $config)
};  

declare function process-model-list() as element(wf:process-models){
  element wf:process-models{  
    for $name in cts:element-values(xs:QName("wf:process-model-name"))  
    return
    element wf:process-model{
      element wf:process-model-name{$name},
      element wf:link{"/LATEST/resources/processmodel?publishedId="||$name}
    }
  }
};

declare function process-model-response($model-name as xs:string) as element(wf:process-models){
  element wf:process-models{
    for $process-model in /wf:process-model-metadata[wf:process-model-name = $model-name]
    let $full-name := $process-model/wf:process-model-full-name/text()
    return
    element wf:process-model{
      element wf:process-model-full-name{$full-name},
      element wf:link{"/LATEST/resources/processmodel?name="||$full-name}
    }
  }  
};



declare function xml-to-html($object as element()){
  typeswitch($object)
    case(element(wf:process-models))
    return
    element html{
      element body{
        element h3{string-util:dash-format-string(fn:local-name($object))}
        ,
        for $element in $object/*
        let $name-element := $element/*[fn:matches(fn:local-name(.),"name")]
        let $link-element := $element/wf:link
        order by $name-element      
        return
        element div{
          let $name-element := $element/*[fn:matches(fn:local-name(.),"name")]
          let $link-element := $element/wf:link
          return
          element div{element a{attribute href{$link-element/text()},$name-element/text()}}
        }        
      }
    }
    default return $object
};

