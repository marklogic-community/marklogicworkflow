xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow-process";

import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";


declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace wf="http://marklogic.com/workflow";


import module namespace wfdefs = "http://marklogic.com/workflow-definitions" at "/app/models/workflow-definitions.xqy";

(:
 : SECURITY NOTICE
 : This file can be executed by anyone with a need to fetch a live process instance
 :)



 (:
  : Returns a process document with the given id
  :)
 declare function m:get($processId as xs:string) as element(wf:process)? {
   let $doc := fn:collection("http://marklogic.com/workflow/processes")/wf:process[./@id = $processId]
   (: Hide elements that a random user is not allowed to see :)
   (: Exceptions - if it's a userTask assigned to a particular user/role :)
   return $doc
 };

 (:
  : Returns the (CPF and MarkLogic Workflow) properties fragment for the given process id
  :)
 declare function m:getProperties($processId as xs:string) as element(prop:properties)? {
   xdmp:document-properties((fn:collection("http://marklogic.com/workflow/processes")/wf:process[./@id = $processId]/fn:base-uri(.)))/prop:properties
 };

 declare function m:getProcessUri($processId as xs:string) as xs:string? {
   (fn:collection("http://marklogic.com/workflow/processes")/wf:process[./@id = $processId]/fn:base-uri(.))
 };
