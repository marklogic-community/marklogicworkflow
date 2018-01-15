xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow-monitoring";

declare namespace wf="http://marklogic.com/workflow";

import module namespace wfdefs = "http://marklogic.com/workflow-definitions" at "/app/models/workflow-definitions.xqy";

(:
 : SECURITY NOTICE
 :
 : Functions in this library should only be executable by those with the workflow-monitor or workflow-administrator privilege.
 :)

(:
 : Lists all processes currently running in MarkLogic. (Does not included those in error by default.)
 :
 : Security - workflow-monitor privilege required (inherited by workflow-administrator role)
 :)
declare function m:processes($username as xs:string?) as element(wf:processes) {
  let $_secure := xdmp:security-assert(($wfdefs:privAdmin,$wfdefs:privMonitor), "execute") (: TODO validate this :)

  return <wf:processes>
  {
    for $process in cts:search(fn:collection("http://marklogic.com/workflow/processes"),
      ),("unfiltered") (: TODO ordering, prioritisation support, and so on :)
    )/wf:process
    return
      <wf:process-details id="{xs:string($process/@id)}">
        <wf:process-data>
        {$process}
        </wf:process-data>
        <wf:process-properties>
        {xdmp:properties-document(fn:base-uri($process))}
        </wf:process-properties>
      </wf:process-details>
  }
  </wf:processes>
};
