xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow-status";

import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";


declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace wf="http://marklogic.com/workflow";


import module namespace wfdefs = "http://marklogic.com/workflow-definitions" at "/app/models/workflow-definitions.xqy";

(:
 : SECURITY NOTICE
 : This file should only be executed by users with the workflow-user privilege
 :)



(:
 : Returns the specified user, or current user, inbox list. Lists all processes in a UserTask (or subclass thereof)
 :)
declare function m:inbox($username as xs:string?) as element(wf:inbox) {
  let $_secure := xdmp:security-assert(($wfdefs:privUser,$wfdefs:privMonitor), "execute")
  (: TODO SECURITY - Check the $username is this user, if don't have the privMonitor privilege :)
  (: NB this should be covered by document permissions anyway, set via wfin:create :)
  return
  <wf:inbox>
  {
    for $process in cts:search(fn:collection("http://marklogic.com/workflow/processes"),
      cts:and-query(
        (: TODO add cpf-active check, wf:status running check, wf:locked-user blank :)
        cts:properties-query(
          cts:element-query(xs:QName("wf:currentStep"),
            cts:element-value-query(xs:QName("wf:assignee"),($username,xdmp:get-current-user())[1])
          )
        )
      ),("unfiltered") (: TODO ordering, prioritisation support, and so on :)
    )
    return
      <wf:task processid="{xs:string($process/wf:process/@id)}">
        <wf:process-data>
        {$process/wf:process}
        </wf:process-data>
        <wf:process-properties>
        {xdmp:document-properties(fn:base-uri($process))}
        </wf:process-properties>
      </wf:task>
  }
  </wf:inbox>
};

(:
 : Returns the queue contents for the named queue
 :)
declare function m:queue($queue as xs:string) as element(wf:queue) {
  let $_secure := xdmp:security-assert(($wfdefs:privUser,$wfdefs:privMonitor), "execute")
  return
  <wf:queue>
  {
    for $process in cts:search(fn:collection("http://marklogic.com/workflow/processes"),
      cts:and-query(
        (: TODO add cpf-active check, wf:status running check, wf:locked-user blank :)
        cts:properties-query(
          cts:element-query(xs:QName("wf:currentStep"),
            cts:element-value-query(xs:QName("wf:queue"),$queue)
          )
        )
      ),("unfiltered") (: TODO ordering, prioritisation support, and so on :)
    )
    return
      <wf:task processid="{xs:string($process/wf:process/@id)}">
        <wf:process-data>
        {$process/wf:process}
        </wf:process-data>
        <wf:process-properties>
        {xdmp:document-properties(fn:base-uri($process))}
        </wf:process-properties>
      </wf:task>
  }
  </wf:queue>
};

(:
 : Returns the queue contents for the named queue
 :)
declare function m:roleinbox($role as xs:string) as element(wf:queue) {
  let $_secure := xdmp:security-assert(($wfdefs:privUser,$wfdefs:privMonitor), "execute")
  return
  <wf:queue>
  {
    for $process in cts:search(fn:collection("http://marklogic.com/workflow/processes"),
      cts:and-query(
        (: TODO add cpf-active check, wf:status running check, wf:locked-user blank :)
        cts:properties-query(
          cts:element-query(xs:QName("wf:currentStep"),
            cts:element-value-query(xs:QName("wf:role"),$role)
          )
        )
      ),("unfiltered") (: TODO ordering, prioritisation support, and so on :)
    )
    return
      <wf:task processid="{xs:string($process/wf:process/@id)}">
        <wf:process-data>
        {$process/wf:process}
        </wf:process-data>
        <wf:process-properties>
        {xdmp:document-properties(fn:base-uri($process))}
        </wf:process-properties>
      </wf:task>
  }
  </wf:queue>
};

(:
 : Lists all processes, or all those with a specific PROCESS__MAJOR__MINOR name
 :)
declare function m:list($processName as xs:string?) as element(wf:list) {
  let $_secure := xdmp:security-assert(($wfdefs:privUser,$wfdefs:privMonitor), "execute")
  return
  <wf:list>
  {
    for $process in cts:search(fn:collection("http://marklogic.com/workflow/processes"),
      cts:and-query(
        if (fn:not(fn:empty($processName))) then
          cts:element-attribute-value-query(xs:QName("wf:process"),xs:QName("title"),$processName)
        else
          cts:not-query(())
      ),("unfiltered") (: TODO ordering, prioritisation support, and so on :)
    )
    return
      <wf:listitem processid="{xs:string($process/wf:process/@id)}">
        <wf:process-data>
        {$process/wf:process}
        </wf:process-data>
        <wf:process-properties>
        {xdmp:document-properties(fn:base-uri($process))}
        </wf:process-properties>
      </wf:listitem>
  }
  </wf:list>
};
