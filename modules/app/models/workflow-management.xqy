xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow-management";

import module namespace ss = "http://marklogic.com/search/subscribe" at "/app/models/lib-search-subscribe.xqy";

declare namespace wf="http://marklogic.com/workflow";

import module namespace wfdefs = "http://marklogic.com/workflow-definitions" at "/app/models/workflow-definitions.xqy";

(:
 : You must create one or more CPF domains for folders or collections that alerts can be evaluated within.
 :)
declare function m:createAlertingDomain($name as xs:string,$type as xs:string,$path as xs:string,$depth as xs:string) as xs:unsignedLong {
  let $_secure := xdmp:security-assert($wfdefs:privManager, "execute")

  return ss:create-domain($name,$type,$path,$depth,("Status Change Handling","Alerting"),xdmp:database-name(xdmp:modules-database()))
};

(:
 : Create a new process subscription
 :)
declare function m:createSubscription($pipelineName as xs:string,$name as xs:string,$domainname as xs:string,$query as cts:query) as xs:string {
  let $_secure := xdmp:security-assert($wfdefs:privManager, "execute")

  let $alert-uri := ss:add-alert($name,$query,(),"/app/models/alert-action-process.xqy",xdmp:database-name(xdmp:modules-database()),
    (<wf:process-name>{$pipelineName}</wf:process-name>))
  let $alert-enabled := ss:cpf-enable($alert-uri,$domainname)
  return $alert-uri
};

(:
 : Fetches a process subscription
 :)
declare function m:getSubscription($name as xs:string) as element()? {
  let $_secure := xdmp:security-assert($wfdefs:privManager, "execute")

  return ss:get-alert("/config/alerts/" || $name)
};
