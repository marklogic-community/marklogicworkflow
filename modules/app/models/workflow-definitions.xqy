xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow-definitions";

(:
 : SECURITY definitions
 :)
declare variable $privDesigner as xs:string := "http://marklogic.com/workflow/privileges/designer"; (: Process MODEL designers :)
declare variable $privManager as xs:string := "http://marklogic.com/workflow/privileges/manager"; (: People who can install and remove process models from the live system :)
declare variable $privAdmin as xs:string := "http://marklogic.com/workflow/privileges/administrator"; (: People who can see and remove live process INSTANCES :)
declare variable $privMonitor as xs:string := "http://marklogic.com/workflow/privileges/monitor"; (: People who can watch (read only) process status :)
declare variable $privInstantiator as xs:string := "http://marklogic.com/workflow/privileges/instantiator"; (: A user who may start a new workflow instance :)
declare variable $privUser as xs:string := "http://marklogic.com/workflow/privileges/user"; (: A workflow user :)
declare variable $privRuntime as xs:string := "http://marklogic.com/workflow/privileges/internal"; (: The internal workflow runtime itself :)
