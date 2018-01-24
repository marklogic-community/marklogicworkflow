xquery version "1.0-ml";

(:
 : case.xqy - Create a new, or modify an existing, MarkLogic Case instance document
 : API spec: https://app.swaggerhub.com/apis/eouthwaite/case-management-api/1.0.1
 :)

module namespace ext = "http://marklogic.com/rest-api/resource/case";

import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";
import module namespace cc="http://marklogic.com/casemanagement/case-crud" at "/casemanagement/models/case-crud.xqy";

declare namespace roxy = "http://marklogic.com/roxy";
declare namespace wf = "http://marklogic.com/workflow";
declare namespace c = "http://marklogic.com/workflow/case";

declare namespace rapi = "http://marklogic.com/rest-api";

(:
 : To add parameters to the functions, specify them in the params annotations.
 : Example
 :   declare %roxy:params("uri=xs:string", "priority=xs:int") ext:get(...)
 : This means that the get function will take two parameters, a string and an int.
 :)

(:
 : Fetch a case by its UUID
 : ?rs:caseid = the string id returned from PUT /resource/case or cc:case-create
 :)
declare
%roxy:params("caseId=xs:string")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"
  let $part := (map:get($params,"part"),"document")[1]

  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)
  let $caseid := map:get($params,"caseId")

  let $out :=
    if (fn:empty($caseid))
    then (
      404, "Case not found", "caseId parameter is required"
    )
    else
      let $case := cc:case-get($caseid, fn:false())
      return
        if ($case)
        then (
          200, "OK",
          <ext:readResponse>
            <ext:outcome>SUCCESS</ext:outcome>
            {$case}
          </ext:readResponse>
        )
        else (
          400, "Invalid ID supplied", fn:concat("caseId ", $caseid, " not found")
        )
  return
    if (200 = $out[1])
    then  (
      xdmp:set-response-code($out[1], $out[2]),
      document {
        if ("application/xml" = $preftype) then
          $out[3]
        else
          let $config := json:config("custom")
          let $cx := map:put($config, "text-value", "label" )
          let $cx := map:put($config , "camel-case", fn:true() )
          return
            json:transform-to-json($out[3], $config)
      }
    )
    else fn:error((),"RESTAPI-SRVEXERR", ($out[1], $out[2], $out[3]))
};

(:
 : Create a new case document instance
 :)

(:
 : Post Endpoint
 :       - create a new case instance, case instance XML can be sent from the client
 :       - generate UID for case.
 :       - TODO permissions - see user authorisation
 :       - TODO maintain audit-trail
 :       - TODO Error Handling!
 :)

declare
%rapi:transaction-mode("update")
%roxy:params("template=xs:string", "permissions=xs:string")
function ext:post(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()? {

  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else
    if ("text/plain" = map:get($context,"accept-types")) then "text/plain" else "application/json"

  let $_ := xdmp:log(fn:concat("context:", xdmp:quote($context)), "debug")
  let $_ := xdmp:log(fn:concat("params:", xdmp:quote($params)), "debug")
  let $_ := xdmp:log(fn:concat("input:", xdmp:quote($input)), "debug")

  (: TODO get permissions from params :)
  let $permissions := map:get($params, "permissions")
  (: TODO make case template name mandatory :)
  let $template-name := (map:get($params, "template"), "notemplate")[1]

  let $out :=
    if (fn:empty($input/element()))
    then (
      405, "Invalid input", "Nothing to insert"
    )
    else
      let $res := cc:case-create($template-name, $input/element(), $permissions, ()) (: Blank template and parent for now :)
      return (
        200, "OK",
        <ext:createResponse><ext:outcome>SUCCESS</ext:outcome><ext:caseId>{$res}</ext:caseId></ext:createResponse>,
        $res
      )

  return
    if (200 = $out[1])
    then (
      map:put($context, "output-types", $preftype),
      xdmp:set-response-code($out[1], $out[2]),
      document {
        if ("application/xml" = $preftype) then
          $out[3]
        else if ("text/plain" = $preftype) then
          $out[4]
        else
          let $config := json:config("custom")
          let $cx := map:put($config, "text-value", "label" )
          let $cx := map:put($config ,"camel-case", fn:true() )
          return
            json:transform-to-json($out[3], $config)
      }
    )
    else fn:error((),"RESTAPI-SRVEXERR", ($out[1], $out[2], $out[3]))
};

(:
 : PUT - update a case instance, potentially changing data and status
 :
 : currently just accepts XML to update whole document.
 :
 :)
declare
%roxy:params("caseId=xs:string")
function ext:put(
   $context as map:map,
   $params  as map:map,
   $input   as document-node()*
) as document-node()? {

  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"

  let $_ := xdmp:log($input)
  let $caseid := map:get($params,"caseId")
  let $_ := xdmp:log(fn:concat("REST EXT caseId: ", $caseid), "debug")
  (: TODO get permissions from params :)
  let $permissions := map:get($params, "permissions")

  let $out :=
    if (fn:empty($caseid))
    then (
     404, "Case not found", "caseId parameter is required"
    )
    else
      if (fn:empty($input/element()))
      then (
        405, "Validation exception", "Nothing to update"
      )
      else
        let $case := cc:case-get($caseid, fn:true())
        return
          if ($case)
          then
            if (fn:true() = cc:case-update($caseid, $input/element(), $permissions, ()))
            then (
              200, "OK",
              <ext:updateResponse><ext:outcome>SUCCESS</ext:outcome></ext:updateResponse>)
            else (
              405, "Validation exception", "Case could not be updated"
            )
          else (
            400, "Invalid ID supplied", fn:concat("caseId ", $caseid, " not found")
          )
  return
    if (200 = $out[1])
    then (
      map:put($context, "output-types", $preftype),
      xdmp:set-response-code($out[1], $out[2]),
      document {
        if ("application/xml" = $preftype) then
          $out[3]
        else
          let $config := json:config("custom")
          let $cx := map:put($config, "text-value", "label" )
          let $cx := map:put($config , "camel-case", fn:true() )
          return
            json:transform-to-json($out[3], $config)
      }
    )
    else fn:error((),"RESTAPI-SRVEXERR", ($out[1], $out[2], $out[3]))
};

