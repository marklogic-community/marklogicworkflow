xquery version "1.0-ml";

module namespace m="http://marklogic.com/case-definitions";

(:
 : SECURITY definitions
 :)
declare variable $privCaseDesigner as xs:string := "http://marklogic.com/workflow/privileges/case-designer"; (: case MODEL designers :)
declare variable $privCaseManager as xs:string := "http://marklogic.com/workflow/privileges/case-manager"; (: People who can install and remove process models from the live system :)
declare variable $privCaseAdmin as xs:string := "http://marklogic.com/workflow/privileges/case-administrator"; (: People who can see and remove live process INSTANCES :)
declare variable $privCaseMonitor as xs:string := "http://marklogic.com/workflow/privileges/case-monitor"; (: People who can watch (read only) process status :)
declare variable $privCaseInstantiator as xs:string := "http://marklogic.com/workflow/privileges/case-instantiator"; (: A user who may start a new workflow instance :)
declare variable $privCaseUser as xs:string := "http://marklogic.com/workflow/privileges/case-user"; (: A workflow user :)
declare variable $privCaseRuntime as xs:string := "http://marklogic.com/workflow/privileges/case-internal"; (: The internal workflow runtime itself :)
