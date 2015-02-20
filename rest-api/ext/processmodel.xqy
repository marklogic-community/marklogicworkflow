xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/processmodel";

declare namespace roxy = "http://marklogic.com/roxy";


(:
 : Get the latest process model
 :  ?[major=numeric[&minor=numeric]]&uri=uri
 :)
declare
%roxy:params("")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{

  (
    map:put($context, "output-types", "text/xml"),
    xdmp:set-response-code(200, "OK"),

    document {
    }
  )
};

(:
 : Publish the process model
 :  ?[major=numeric[&minor=numeric]]&name=name
 :)
declare
%roxy:params("")
function ext:put(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()?
{
  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"

  let $_ := xdmp:log($input)

  let $modelid := wfu:install-and-convert(map:get($params,"name"),$input,(map:get($params,"major"),"1")[1],(map:get($params,"minor"),"0")[1] )

  let $out := <ext:createResponse><ext:outcome>SUCCESS</ext:outcome><ext:modelId>{$modelid}</ext:modelId></ext:createResponse>

  return
  (
    map:put($context, "output-types", "application/json"),
    xdmp:set-response-code(200, "OK"),
    document { "PUT called on rest api"
      (: 1. Take the process model document and convert to a CPF pipeline document :)
      (: 2. Add a CPF pipeline by using a directory scope of /cpf/processes/ (<PROCURI>/<UUID.xml>) depth infinite :)
      (: 3. Optionally enable :)

        if ("application/xml" = $preftype) then
          $out
        else
          "{TODO:'TODO'}"
    }

  )
};

(:
 : Add a new process model version.
 : ?major=numeric&minor=numeric&name=name
 :)
declare
%roxy:params("")
function ext:post(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()*
{
  (
    map:put($context, "output-types", "application/json"),
    xdmp:set-response-code(200, "OK"),
    document { "POST called on rest api" }
  )
};



(:
 : Remove the specified process model from execution
 :  ?[major=numeric[&minor=numeric]]&modelid=modelid
 :)
declare function ext:delete(
    $context as map:map,
    $params  as map:map
) as document-node()? {
  let $name := map:get($params,"something")
  let $l := xdmp:log("DELETE /v1/resources/processmodel CALLED")
  let $l := xdmp:log($params)
  let $l := xdmp:log($context)
  return (xdmp:set-response-code(200,"OK"),document {



   })
};
