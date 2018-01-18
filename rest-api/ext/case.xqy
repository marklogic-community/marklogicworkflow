xquery version "1.0-ml";

(:
 : case.xqy - Create a new, or modify an existing, MarkLogic Case instance document
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
 : Create a new case document instance
 :)

(:
 : Creates a new case document instance with the given data
 :
 : Expects:=
 : <ext:createRequest>
 :  <ext:caseTemplateName>MyCaseTemplate</ext:caseTemplateName>
 :  <ext:data>
 :    <ns1:choiceA>B</ns1:choiceA><ns1:choiceB>C</ns1:choiceB>
 :  </ext:data>
 :  <ext:attachments>
 :    <c:attachment uri="some ml uri" />
 :  </ext:attachments>
 : </ext:createRequest>
 :)
declare
%rapi:transaction-mode("update")
%roxy:params("") (:  :)
function ext:post(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()? {

  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else
    if ("text/plain" = map:get($context,"accept-types")) then "text/plain" else "application/json"

  (: TODO make case template name mandatory :)

  let $_ := xdmp:log(fn:concat("context:", xdmp:quote($context)), "debug")
  let $_ := xdmp:log(fn:concat("params:", xdmp:quote($params)), "debug")
  let $_ := xdmp:log(fn:concat("input:", xdmp:quote($input)), "debug")

  let $res := cc:case-create($input/element(), ()) (: Blank parent case id for now :)

  let $out := <ext:createResponse><ext:outcome>SUCCESS</ext:outcome><ext:caseId>{$res}</ext:caseId></ext:createResponse>

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
 : Fetch a case by its UUID
 : ?rs:caseid = the string id returned from PUT /resource/case or cc:case-create
 :)
declare
%roxy:params("caseid=xs:string") (: "transactionId=xs:string" :)
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"
  let $part := (map:get($params,"part"),"document")[1]

  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)
  let $caseid := map:get($params,"caseid")

  let $out :=
    if (fn:empty($caseid)) then
      <ext:readResponse><ext:outcome>FAILURE</ext:outcome><ext:details>caseId parameter is required</ext:details></ext:readResponse>
    else
      let $case := cc:case-get($caseid, fn:false())
      return
        if ($case)
        then
          <ext:readResponse>
            <ext:outcome>SUCCESS</ext:outcome>
            {$case}
          </ext:readResponse>
        else
          <ext:readResponse><ext:outcome>FAILURE</ext:outcome><ext:details>caseId {$caseid} not found</ext:details></ext:readResponse>
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




(:
 : PUT - update a case instance, potentially changing data and status
 :
 : PUT process?rs:caseid=1234&updatetag=ABCD1234&rs:close=true -> Closed case. Respects locks. (optionally) updates case data.
 : PUT process?rs:caseid=1234&updatetag=ABCD1234&rs:lock=true -> Locks the case for the current user. (optionally) updates case data. Respects locks.
 : PUT process?rs:caseid=1234&updatetag=ABCD1234&rs:unlock=true -> Unlocks the case if locked by current user. (optionally) updates case data. Respects locks.
 :) (:
declare
%roxy:params("")
function ext:put(
   $context as map:map,
   $params  as map:map,
   $input   as document-node()*
) as document-node()* {

 let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"

 let $_ := xdmp:log($input)
 let $caseid := map:get($params,"caseid")
 let $_ := xdmp:log("REST EXT caseId: " || $caseid)
 let $case := cc:case-get($caseid,fn:false())

 let $res :=
   if ("true" = map:get($params,"close")) then
     if (fn:true() = cc:case-close($caseid,xs:string(map:get($params,"updatetag")),
       $input/ext:updateRequest/ext:data/element(),$input/ext:updateRequest/ext:attachments/c:attachment) ) then
       <ext:updateResponse><ext:outcome>SUCCESS</ext:outcome></ext:updateResponse>
     else
       <ext:updateResponse><ext:outcome>FAILURE</ext:outcome><ext:message>Case could not be closed.</ext:message><ext:feedback></ext:feedback></ext:updateResponse>
   else
     if (fn:true() = cc:case-update($caseid,xs:string(map:get($params,"updatetag")),
       $input/ext:updateRequest/ext:data/element(),$input/ext:updateRequest/ext:attachments/c:attachment)) then
       <ext:updateResponse><ext:outcome>SUCCESS</ext:outcome></ext:updateResponse>
     else
       <ext:updateResponse><ext:outcome>FAILURE</ext:outcome><ext:message>Case could not be updated.</ext:message><ext:feedback></ext:feedback></ext:updateResponse>

  return
  (
    map:put($context, "output-types", $preftype),
    xdmp:set-response-code(200, "OK"),
    document {
      if ("application/xml" = $preftype) then
        $res
      else
        let $config := json:config("custom")
        let $cx := map:put($config, "text-value", "label" )
        let $cx := map:put($config , "camel-case", fn:true() )
        return
          json:transform-to-json($res, $config)
    }
  )
};
:)
