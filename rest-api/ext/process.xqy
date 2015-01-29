

(: process.xqy - Start a new, or modify an existing, MarkLogic Workflow process
 :
 :)
xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/process";

(: import module namespace config = "http://marklogic.com/roxy/config" at "/app/config/config.xqy"; :)
import module namespace json6 = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

declare namespace roxy = "http://marklogic.com/roxy";

(:
 : To add parameters to the functions, specify them in the params annotations.
 : Example
 :   declare %roxy:params("uri=xs:string", "priority=xs:int") ext:get(...)
 : This means that the get function will take two parameters, a string and an int.
 :)

(:
 : Create a new process instance
 :)

(:
 : Uploads workplace pages, complimenting those that already exist
 : Expects:=
 : <ext:createRequest>
 :  <ext:processName>ProcessName__1__0</ext:processName>
 :  <ext:data>
 :    <ns1:choiceA>B</ns1:choiceA><ns1:choiceB>C</ns1:choiceB>
 :  </ext:data>
 :  <ext:attachments>
 :    <wf:attachment>format TBD</wf:attachment>
 :  </ext:attachments>
 : </ext:createRequest>
 :)
declare
%roxy:params("")
function ext:put(
    $context as map:map,
    $params  as map:map,
    $input   as document-node()*
) as document-node()* {

  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"

  let $_ := xdmp:log($input)

  let $res := m:create($input/ext:createRequest/ext:processName/text(),
    $input/ext:createRequest/ext:data/element(),$input/ext:createRequest/ext:attachments/wf:attachment)

  let $out := <ext:createResponse><ext:outcome>SUCCESS</ext:outcome><ext:processId>{$res}</ext:processId></ext:createResponse>

  return
    map:put($context, "output-types", $preftype),
    xdmp:set-response-code(200, "OK"),
    document {
      if ("application/xml" = $preftype) then
        $out
      else
        TODO
    }
};


(:
 : Fetch a process by its UUID
 : ?processId = the string id returned from POST /resource/process or wfu:create
 : ?part = 'document' (default), or 'properties' (returns CPF and Workflow properties fragment), or 'both'
 :)
declare
%roxy:params("processId=xs:string","part=xs:string")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"
  let $part := (map:get($params,"part"),"document")[1]

  let $out :=
    if (fn:empty(map:get($params,"processId"))) then
      <ext:readResponse><ext:outcome>FAILURE</ext:outcome><ext:details>processId parameter is required</ext:details></ext:readResponse>
    else
      <ext:readResponse><ext:outcome>SUCCESS</ext:outcome>
        {if ($part = "document") then
          <ext:document>{wfu:get(map:get($params,"processId"))}</ext:document>
         else if ($part = "properties") then
           <ext:properties>{wfu:getProperties(map:get($params,"processId"))}</ext:properties>
         else
           <ext:document>{wfu:get(map:get($params,"processId"))}</ext:document>
           <ext:properties>{wfu:getProperties(map:get($params,"processId"))}</ext:properties>
        }
      </ext:readResponse>

  return
  (
    xdmp:set-response-code(200, "OK"),
    document {
      if ("application/xml" = $preftype) then
        $out
      else
        TODO
    }
  )
};
