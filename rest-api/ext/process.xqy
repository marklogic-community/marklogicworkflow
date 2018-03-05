(: process.xqy - Start a new, or modify an existing, MarkLogic Workflow process
 :
 :)
xquery version "1.0-ml";

module namespace ext = "http://marklogic.com/rest-api/resource/process";

(: import module namespace config = "http://marklogic.com/roxy/config" at "/app/config/config.xqy"; :)
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";
import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace wfu="http://marklogic.com/workflow-util" at "/workflowengine/models/workflow-util.xqy";
import module namespace wfa="http://marklogic.com/workflow-actions" at "/workflowengine/models/workflow-actions.xqy";

declare namespace rapi = "http://marklogic.com/rest-api";
declare namespace roxy = "http://marklogic.com/roxy";
declare namespace wf="http://marklogic.com/workflow";

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
) as document-node()? {

  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else
    if ("text/plain" = map:get($context,"accept-types")) then "text/plain" else "application/json"

  let $_ := xdmp:log($input)

  let $res := wfu:create($input/ext:createRequest/ext:processName/text(),
    $input/ext:createRequest/ext:data/element(),$input/ext:createRequest/ext:attachments/wf:attachment,(),(),())

  let $out := <ext:createResponse><ext:outcome>SUCCESS</ext:outcome><ext:processId>{$res}</ext:processId></ext:createResponse>

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
        let $cx := map:put($config, "array-element-names",(xs:QName("wf:audit"),xs:QName("wf:metric")))
        let $cx := map:put($config, "text-value", "label" )
        let $cx := map:put($config , "camel-case", fn:true() )
        return
          json:transform-to-json($out, $config)
    }
  )
};


(:
 : Fetch a process by its UUID
 : ?processId = the string id returned from POST /resource/process or wfu:create
 : ?part = 'document' (default), or 'properties' (returns CPF and Workflow properties fragment), or 'both'
 :)
declare
%roxy:params("processid=xs:string","part=xs:string")
function ext:get(
  $context as map:map,
  $params  as map:map
) as document-node()*
{
  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"
  let $part := (map:get($params,"part"),"document")[1]

  let $_ := xdmp:log($params)
  let $_ := xdmp:log($context)

  let $out :=
    if (fn:empty(map:get($params,"processid"))) then
      <ext:readResponse><ext:outcome>FAILURE</ext:outcome><ext:details>processId parameter is required</ext:details></ext:readResponse>
    else
      <ext:readResponse><ext:outcome>SUCCESS</ext:outcome>
        {if ($part = "document") then
          <ext:document>{wfu:get(map:get($params,"processid"))}</ext:document>
         else if ($part = "properties") then
           <ext:properties>{wfu:getProperties(map:get($params,"processid"))}</ext:properties>
         else
           (<ext:document>{wfu:get(map:get($params,"processid"))}</ext:document>,
           <ext:properties>{wfu:getProperties(map:get($params,"processid"))}</ext:properties>)
        }
      </ext:readResponse>

  return
  (
    xdmp:set-response-code(200, "OK"),
    document {
      if ("application/xml" = $preftype) then
        $out
      else
        let $config := json:config("custom")
        let $cx := map:put($config, "array-element-names",(xs:QName("wf:audit"),xs:QName("wf:metric")))                
        let $cx := map:put($config, "text-value", "label" )
        let $cx := map:put($config , "camel-case", fn:true() )
        return
          json:transform-to-json($out, $config)
    }
  )
};





(:
 : POST - update a process instance, potentially completing it (e.g. human step)
 :
 : POST process?processid=1234 -> Updates data only, does not lock or unlock item. DEPRECATED in current form - In future this will respect locks. Does not yet.
 : POST process?processid=1234&complete=true -> Completes work item. Respects locks. (optionally) updates work item data.
 : POST process?processid=1234&lock=true -> Locks the work item for the current user. (optionally) updates work item data. Respects locks.
 : POST process?processid=1234&unlock=true -> Unlocks the work item if locked by current user. (optionally) update work item data. Respects locks.
 :)
declare
%roxy:params("")
%rapi:transaction-mode("update")
function ext:post(
   $context as map:map,
   $params  as map:map,
   $input   as document-node()*
) as document-node()* {
  let $_ := xdmp:log(fn:concat("REST EXT params=", xdmp:quote($params)), "debug")
  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"
  let $_ := xdmp:log(fn:concat("REST EXT preftype: " , $preftype), "debug")

  let $part := (map:get($params,"part"),"document")[1]
  let $_ := xdmp:log(fn:concat("REST EXT part: ", $part), "debug")

  let $_ := xdmp:log(fn:concat("REST EXT input: ", $input), "debug")
  let $pid := map:get($params,"processid") (: this is stripping the '+' symbol if sent unencoded :)
  (:let $proc := wfu:get($pid):)
  let $_ := xdmp:log(fn:concat("REST EXT ProcessId: ", $pid), "debug")
  let $props := wfu:getProperties($pid)

  let $_ := xdmp:log("CURRENT STEP INFO", "debug")
  let $_ := xdmp:log($props (: /wf:currentStep :) , "debug")

  let $res :=
   if ("true" = map:get($params,"complete")) then
     (: sanity check that the specified process' status is on a user task :)
     if ("userTask" = $props/wf:currentStep/wf:step-type) then
       (: OK :)

       (: call wfu complete on it :)
       let $_ := xdmp:log("Calling wfa:complete-userTask")
       let $feedback := wfa:complete-userTask($pid, $input/wf:data/node(), $input/wf:attachments/node())
       (: let $feedback := wfa:complete-userTask($pid,$input/ext:updateRequest/wf:data/node(),$input/ext:updateRequest/wf:attachments/node()) :)
       (: Could return errors with data or attachments :)
       return
         if (fn:not(fn:empty($feedback))) then
           <ext:updateResponse><ext:outcome>FAILURE</ext:outcome><ext:message>Data Feedback</ext:message><ext:feedback>{$feedback}</ext:feedback></ext:updateResponse>
         else ()
       (: wfu:complete( fn:base-uri($proc), $props/cpf:state/text(), (), fn:current-dateTime() ) :)

     else
       (: error - cannot call complete on non completable task :)
       <ext:updateResponse><ext:outcome>FAILURE</ext:outcome><ext:message>Cannot call complete on non completable task: {$props/wf:step-type/text()}</ext:message></ext:updateResponse>
   else

     if ("true" = map:get($params,"lock")) then
       (: Lock the work item, and return its details as if get had been called. If already locked, instead return an error :)
       let $_ := xdmp:log("REST EXT call to lock work item", "debug")
       let $feedback := wfu:lock($pid)
       let $update :=
         if (fn:empty($feedback)) then
           <ext:readResponse><ext:outcome>SUCCESS</ext:outcome>
             {if ($part = "document") then
               <ext:document>{wfu:get(map:get($params,"processid"))}</ext:document>
              else if ($part = "properties") then
                <ext:properties>{wfu:getProperties(map:get($params,"processid"))}</ext:properties>
              else
                (<ext:document>{wfu:get(map:get($params,"processid"))}</ext:document>,
                <ext:properties>{wfu:getProperties(map:get($params,"processid"))}</ext:properties>)
             }
           </ext:readResponse>
         else
           <ext:updateResponse><ext:outcome>FAILURE</ext:outcome><ext:message>Work item could not be locked by user.</ext:message><ext:feedback>{$feedback}</ext:feedback></ext:updateResponse>
        return
          if (fn:empty($feedback)) then
            let $fb := wfa:update-userTask($pid,$input/ext:updateRequest/wf:data/node(),$input/ext:updateRequest/wf:attachments/node())
            return
              if (fn:not(fn:empty($fb))) then
                <ext:updateResponse><ext:outcome>FAILURE</ext:outcome><ext:message>Could not update userTask</ext:message><ext:feedback>{$fb}</ext:feedback></ext:updateResponse>
              else
                $update
          else
            $update
      else
        if ("true" = map:get($params,"unlock")) then
          let $feedback := wfu:unlock($pid)
          let $update :=
           if (fn:empty($feedback)) then
            <ext:readResponse><ext:outcome>SUCCESS</ext:outcome>
              {if ($part = "document") then
                <ext:document>{wfu:get(map:get($params,"processid"))}</ext:document>
               else if ($part = "properties") then
                 <ext:properties>{wfu:getProperties(map:get($params,"processid"))}</ext:properties>
               else
                 (<ext:document>{wfu:get(map:get($params,"processid"))}</ext:document>,
                 <ext:properties>{wfu:getProperties(map:get($params,"processid"))}</ext:properties>)
              }
            </ext:readResponse>
           else
            <ext:updateResponse><ext:outcome>FAILURE</ext:outcome><ext:message>Work item could not be unlocked by user.</ext:message><ext:feedback>{$feedback}</ext:feedback></ext:updateResponse>
          return
            if (fn:empty($feedback)) then
              let $fb := wfa:update-userTask($pid,$input/ext:updateRequest/wf:data/node(),$input/ext:updateRequest/wf:attachments/node())
              return
                if (fn:not(fn:empty($fb))) then
                  <ext:updateResponse><ext:outcome>FAILURE</ext:outcome><ext:message>Could not update userTask</ext:message><ext:feedback>{$fb}</ext:feedback></ext:updateResponse>
                else
                  $update
            else
              $update
        else
          (: Just default to updating the data, but doing nothing around locking :)
          wfa:update-userTask($pid,$input/ext:updateRequest/wf:data/node(),$input/ext:updateRequest/wf:attachments/node())


 let $out := ($res,<ext:updateResponse><ext:outcome>SUCCESS</ext:outcome></ext:updateResponse>)[1]

  return
  (
    map:put($context, "output-types", $preftype),
    xdmp:set-response-code(200, "OK"),
    document {
      if ("application/xml" = $preftype) then
        $out
      else
        let $config := json:config("custom")
        let $cx := map:put($config, "array-element-names",(xs:QName("wf:audit"),xs:QName("wf:metric")))        
        let $cx := map:put($config, "text-value", "label" )
        let $cx := map:put($config , "camel-case", fn:true() )
        return
          json:transform-to-json($out, $config)
    }
  )
};

declare
%roxy:params("")
function ext:delete(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
) as document-node()* {

  let $preftype := if ("application/xml" = map:get($context,"accept-types")) then "application/xml" else "application/json"

  let $pid := map:get($params,"processid")
  let $_ := xdmp:log("REST EXT ProcessId: " || $pid)
  let $_ := wfu:delete($pid)

  return
    (
      map:put($context, "output-types", $preftype),
      xdmp:set-response-code(200, "OK"),
      document {()}
    )
};

