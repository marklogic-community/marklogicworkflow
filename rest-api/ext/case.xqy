xquery version "1.0-ml";

(:
 : case.xqy - Create a new, or modify an existing, MarkLogic Case instance document
 : API spec: https://app.swaggerhub.com/apis/eouthwaite/case-management-api/1.0.1
 :)

module namespace ext = "http://marklogic.com/rest-api/resource/case";

import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";
import module namespace ch="http://marklogic.com/casemanagement/controller-helper" at "/casemanagement/models/controller-helper.xqy";
import module namespace clib="http://marklogic.com/casemanagement/case-lib" at "/casemanagement/models/case-lib.xqy";

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
 : ?rs:caseid = the string id returned from PUT /resource/case or ch:case-create
 :)
declare
%roxy:params("caseId=xs:string")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"

  let $_ := xdmp:log("REST EXT GET:", "debug")
  let $_ := xdmp:log(fn:concat("context:", xdmp:quote($context)), "debug")
  let $_ := xdmp:log(fn:concat("params:", xdmp:quote($params)), "debug")

  let $validate := ch:validation("get case", $params, ())
  let $status-code := map:get($validate,"status-code")
  let $response-message := map:get($validate,"response-message")
  return
    if (200 = $status-code)
    then
      let $document := (: TODO - permissions: what if clib:get-case-document fails... :)
        <ext:readResponse>
          <ext:outcome>SUCCESS</ext:outcome>
          {clib:get-case-document( map:get($validate,"caseId") )}
        </ext:readResponse>
      return (
        map:put($context, "output-types", $preftype),
        xdmp:set-response-code($status-code, $response-message),
        document {
          if ("application/xml" = $preftype) then
            $document
          else
            let $config := json:config("custom")
            let $cx := map:put($config, "text-value", "label")
            let $cx := map:put($config, "camel-case", fn:true())
            return
              json:transform-to-json(map:get($validate,"document"), $config)
        }
      )
    else fn:error((), "RESTAPI-SRVEXERR", ($status-code, $response-message, map:get($validate,"error-detail")))
};

(:
 : Create a new case document instance
 :)

(:
 : Post Endpoint
 :       - create a new case instance, case instance XML can be sent from the client
 :       - generate UID for case.
 :       - TODO maintain audit-trail
 :       - TODO Error Handling!
 :)

declare
%rapi:transaction-mode("update")
%roxy:params("template=xs:string", "permission=xs:string")
function ext:post(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()? {

  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else
    if ("text/plain" = map:get($context,"accept-types")) then "text/plain" else "application/json"

  let $_ := xdmp:log("REST EXT POST:", "debug")
  let $_ := xdmp:log(fn:concat("context:", xdmp:quote($context)), "debug")
  let $_ := xdmp:log(fn:concat("params:", xdmp:quote($params)), "debug")
  let $_ := xdmp:log(fn:concat("input:", xdmp:quote($input)), "debug")

  let $permissions := map:get($params, "permission")
  (: TODO make case template name mandatory :)
  let $template-name := (map:get($params, "template"), "notemplate")[1]
  let $case-doc := $input/element(c:case)

  let $validate := ch:validation("new case", $params, $case-doc)
  let $status-code := map:get($validate,"status-code")
  let $response-message := map:get($validate,"response-message")
  return
    if (200 = $status-code)
    then
      let $caseid := map:get($validate, "caseId")
      let $res := ch:case-create($caseid, $template-name, $case-doc, map:get($validate, "permissions"), ()) (: Blank template and parent for now :)
      return (
        map:put($context, "output-types", $preftype),
        xdmp:set-response-code($status-code, $response-message),
        document {
          if ("application/xml" = $preftype) then
            <ext:createResponse><ext:outcome>SUCCESS</ext:outcome><ext:caseId>{$res}</ext:caseId></ext:createResponse>
          else if ("text/plain" = $preftype) then
            $res
          else
            let $config := json:config("custom")
            let $cx := map:put($config, "text-value", "label" )
            let $cx := map:put($config ,"camel-case", fn:true() )
            return
              json:transform-to-json($res, $config)
        }
      )
    else fn:error((),"RESTAPI-SRVEXERR", ($status-code, $response-message, map:get($validate,"error-detail")))
};

(:
 : PUT - update a case instance, potentially changing data and status
 :
 : currently just accepts XML to update whole document.
 :
 :)
declare
%roxy:params("caseId=xs:string", "permission=xs:string")
function ext:put(
   $context as map:map,
   $params  as map:map,
   $input   as document-node()*
) as document-node()? {

  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"

  let $_ := xdmp:log("REST EXT PUT:", "debug")
  let $_ := xdmp:log(fn:concat("context:", xdmp:quote($context)), "debug")
  let $_ := xdmp:log(fn:concat("params:", xdmp:quote($params)), "debug")
  let $_ := xdmp:log(fn:concat("input:", xdmp:quote($input)), "debug")
  let $case-doc := $input/element(c:case)

  let $validate := ch:validation("update case", $params, $case-doc)
  let $status-code := map:get($validate,"status-code")
  let $response-message := map:get($validate,"response-message")

  let $out :=
    if (200 = $status-code)
    then
      if (fn:true() = ch:case-update(map:get($validate, "caseId"), $case-doc, map:get($validate, "permissions"), ()))
      then <ext:updateResponse><ext:outcome>SUCCESS</ext:outcome></ext:updateResponse>
      else
        let $validate := map:new((
          map:entry("status-code", 405),
          map:entry("response-message", "Validation exception"),
          map:entry("error-detail", "Case could not be updated")
        ))
        return ()
    else ()
  return
    if (200 = $status-code)
    then (
      map:put($context, "output-types", $preftype),
      xdmp:set-response-code($status-code, $response-message),
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
    else fn:error((),"RESTAPI-SRVEXERR", ($status-code, $response-message, map:get($validate,"error-detail")))
};

