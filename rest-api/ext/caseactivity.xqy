xquery version "1.0-ml";

(:
 : caseactivity.xqy - Create a new, or modify an existing activity within a MarkLogic Case instance document
 : API spec: https://app.swaggerhub.com/apis/eouthwaite/case-management-api/1.0.1
 :)

module namespace ext = "http://marklogic.com/rest-api/resource/caseactivity";

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
 : Fetch a caseactivity by its UUID
 : ?rs:caseid = the string id returned from PUT /resource/caseactivity or ch:caseactivity-create
 :)
declare
%roxy:params("activityId=xs:string")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"

  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)

  let $_ := xdmp:log(fn:concat("about to call validation action name:", "get activity", " params:", xdmp:quote($params)) (:, "debug":) )

  let $validate := ch:validation("get activity", $params, ())
  let $_ := xdmp:log(fn:concat("validate:", xdmp:quote($validate)), "debug")

  let $status-code := map:get($validate,"status-code")
  let $response-message := map:get($validate,"response-message")
  return
    if (200 = $status-code)
    then
      let $document := (: TODO - what if clib:get-activity-document fails... :)
        <ext:readResponse>
          <ext:outcome>SUCCESS</ext:outcome>
          {clib:get-activity-document(map:get($validate,"activityId"))}
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
 : Create a new caseactivity document instance
 :)

(:
 : Post Endpoint
 :       - create a new caseactivity instance; XML can be sent from the client
 :       - generate UID for case.
 :       - TODO permissions - see user authorisation
 :       - TODO maintain audit-trail
 :       - TODO Error Handling!
 :)

declare
%rapi:transaction-mode("update")
%roxy:params("caseId=xs:string", "phaseId=xs:string")
function ext:post(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()? {

  let $preftype := if ("application/xml" = map:get($context, "accept-types")) then "application/xml" else
    if ("text/plain" = map:get($context, "accept-types")) then "text/plain" else "application/json"

  let $_ := xdmp:log(fn:concat("context:", xdmp:quote($context)), "debug")
  let $_ := xdmp:log(fn:concat("params:", xdmp:quote($params)), "debug")
  let $_ := xdmp:log(fn:concat("input:", xdmp:quote($input)), "debug")

  let $activity-doc := $input/element(c:activity)
  (:
  let $caseid := map:get($params, "caseId")
  let $phaseid := map:get($params, "phaseId")
  let $activityid := clib:get-new-id($activity-doc)
:)

  (:  let $validate := ch:validate($caseid, fn:false(), $activityid, fn:true(), fn:exists($activity-doc), fn:true()) ( : TODO - check whether phase is new too? :)
  let $validate := ch:validation("new activity", $params, $activity-doc)
  let $status-code := map:get($validate,"status-code")
  let $response-message := map:get($validate,"response-message")
  return
    if (200 = $status-code)
    then
      let $res := ch:caseactivity-create(
        map:get($validate, "caseId"),
        map:get($validate, "phaseId"),
        map:get($validate, "activityId"),
        $activity-doc)
      (: TODO: what to do if this fails :)
      return (
        map:put($context, "output-types", $preftype),
        xdmp:set-response-code($status-code, $response-message),
        document {
          if ("application/xml" = $preftype) then
            <ext:createResponse><ext:outcome>SUCCESS</ext:outcome><ext:caseactivityId>{$res}</ext:caseactivityId></ext:createResponse>
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
    else fn:error((),"RESTAPI-SRVEXERR", ($status-code, $response-message, map:get($validate, "error-detail")))
};

(:
 : PUT - update a case activity instance, potentially changing data and status
 :
 : accepts XML containing sections to update and replaces them within the
 : matching c:case/c:phases/c:phase/c:activities/c:activity element
 :
 :)
declare
%rapi:transaction-mode("update")
%roxy:params("activityId=xs:string", "patch=xs:string")
function ext:put(
   $context as map:map,
   $params  as map:map,
   $input   as document-node()*
) as document-node()? {
  let $_ := xdmp:log(fn:concat("context:", xdmp:quote($context)), "debug")
  let $_ := xdmp:log(fn:concat("params:", xdmp:quote($params)), "debug")
  let $_ := xdmp:log(fn:concat("input:", xdmp:quote($input)), "debug")

  return
    if (map:contains($params, "patch"))
    then ext:patch($context, $params, $input)
    else

  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"
  let $activity-doc := $input/element(c:activity)
  let $validate := ch:validation("update activity", $params, $activity-doc)

  let $status-code := map:get($validate,"status-code")
  let $response-message := map:get($validate,"response-message")

  let $out :=
    if (200 = $status-code)
    then
      let $res := ch:caseactivity-update(map:get($validate,"activityId"), $activity-doc)
      return <ext:updateResponse><ext:outcome>SUCCESS</ext:outcome></ext:updateResponse>
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

(:
 : PATCH - update a case activity instance, potentially changing data and status
 :
 : currently same as PUT
 :
 :)
declare
%rapi:transaction-mode("update")
%roxy:params("activityId=xs:string")
function ext:patch(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
) as document-node()? {

  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"
  let $_ := xdmp:log(fn:concat("context:", xdmp:quote($context)), "debug")
  let $_ := xdmp:log(fn:concat("params:", xdmp:quote($params)), "debug")
  let $_ := xdmp:log(fn:concat("input:", xdmp:quote($input)), "debug")

  let $patch-doc := $input/element(rapi:patch)
  let $validate := ch:validation("patch activity", $params, $patch-doc)

  let $status-code := map:get($validate,"status-code")
  let $response-message := map:get($validate,"response-message")

  let $out :=
    if (200 = $status-code)
    then
      let $res := ch:caseactivity-patch(map:get($validate, "activityId"), map:get($validate, "patches"))
      return <ext:updateResponse><ext:outcome>SUCCESS</ext:outcome><ext:patchOutcome>{$res}</ext:patchOutcome></ext:updateResponse>
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



