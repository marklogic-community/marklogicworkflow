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


  map:put($context, "output-types", "text/xml"),
  xdmp:set-response-code(200, "OK"),

  document {
  }
};

(:
 : Publish the process model
 :  ?[major=numeric[&minor=numeric]]&uri=uri
 :)
declare
%roxy:params("")
function ext:post(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()*
{
  map:put($context, "output-types", "application/json"),
  xdmp:set-response-code(200, "OK"),
  document { "POST called on rest api"
    (: 1. Take the process model document and convert to a CPF pipeline document :)
    (: 2. Add a CPF pipeline by using a directory scope of /cpf/processes/ (<PROCURI>/<UUID.xml>) depth infinite :)
    (: 3. Optionally enable )

  }
};

(:
 : Add a new process model version.
 : ?major=numeric&minor=numeric&uri=uri
 :)
declare
%roxy:params("")
function ext:post(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()*
{
  map:put($context, "output-types", "application/json"),
  xdmp:set-response-code(200, "OK"),
  document { "POST called on rest api" }
};



(:
 : Remove the specified process model from execution
 :  ?[major=numeric[&minor=numeric]]&uri=uri
 :)
declare function ext:delete(
    $context as map:map,
    $params  as map:map
) as document-node()? {
  let $name := map:get($params,"triggername")
  let $database := map:get($params,"triggersdatabase")
  let $l := xdmp:log("DELETE /v1/resources/triggers CALLED")
  let $l := xdmp:log($params)
  let $l := xdmp:log($context)
  return (xdmp:set-response-code(200,"OK"),document {



   })
};
