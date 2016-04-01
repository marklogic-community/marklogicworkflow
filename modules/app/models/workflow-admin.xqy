xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow-admin";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";

declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace wf="http://marklogic.com/workflow";
declare namespace p="http://marklogic.com/cpf/pipelines";
declare namespace error="http://marklogic.com/xdmp/error";

import module namespace wfdefs = "http://marklogic.com/workflow-definitions" at "/app/models/workflow-definitions.xqy";

(:
 : SECURITY NOTICE
 :
 : Functions in this library should only be executable by those with the workflow-administrator privilege.
 :)



(:
 : SECURITY - workflow-administrator privilege required
 :)
declare function m:terminate($processIds as xs:string*) as element(wf:processes) {
  let $_secure := xdmp:security-assert($wfdefs:privAdmin, "execute")

  return <wf:processes>
  {
      for $process-uri in cts:search(fn:collection("http://marklogic.com/workflow/processes"),
        cts:and-query(
          cts:properties-query(
            cts:or-query(
              (
                cts:element-value-query(xs:QName("wf:status"),"INITIALISING"),
                cts:element-value-query(xs:QName("wf:status"),"RUNNING"),
                cts:element-value-query(xs:QName("wf:status"),"WAITING")
              )
            )
          ),
        if (fn:empty($processIds)) then () else
          cts:or-query(
              for $pid in $processIds
              return cts:element-attribute-value-query(xs:QName("wf:process"),xs:QName("wf:pid"),$pid)
          )
        ),("unfiltered") (: TODO ordering, prioritisation support, and so on :)
      )/wf:process/fn:base-uri(.)
      let $term := xdmp:node-replace(xdmp:document-properties($process-uri)/prop:properties/wf:status,
        <wf:status by="{xdmp:get-current-user()}" when="{fn:current-dateTime()}">TERMINATED</wf:status>)
      return
        <wf:process-summary id="{xs:string(fn:doc($process-uri)/wf:process/@id)}" />
  }
  </wf:processes>
};

(:
 : TODO complete this - do we want to return any further summary data on the processes?
 :)
declare function m:processes($processIds as xs:string*) as element(wf:processes) {
  <wf:processes>
  {
      for $process-uri in cts:search(fn:collection("http://marklogic.com/workflow/processes"),
        cts:and-query(
          cts:properties-query(
            cts:or-query(
              (
                cts:element-value-query(xs:QName("wf:status"),"INITIALISING"),
                cts:element-value-query(xs:QName("wf:status"),"RUNNING"),
                cts:element-value-query(xs:QName("wf:status"),"WAITING")
              )
            )
          ),
        if (fn:empty($processIds)) then () else
          cts:or-query(
              for $pid in $processIds
              return cts:element-attribute-value-query(xs:QName("wf:process"),xs:QName("wf:pid"),$pid)
          )
        ),("unfiltered") (: TODO ordering, prioritisation support, and so on :)
      )/wf:process/fn:base-uri(.)
      return
        <wf:process-summary id="{xs:string(fn:doc($process-uri)/wf:process/@id)}" />
  }</wf:processes>
};
