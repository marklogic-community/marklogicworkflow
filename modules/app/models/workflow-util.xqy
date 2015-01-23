xquery version "1.0-ml";

module namespace m="http://marklogic.com/workflow-util";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";
import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";

declare namespace wf="http://marklogic.com/workflow";
declare namespace p="http://marklogic.com/cpf/pipelines";

(:
 : Create a new process and activate it.
 :)
declare function m:create($pipelineName as xs:string,$data as element()*,$attachments as element()*) as xs:string {
  let $uri := "/workflow/process"||$pipelineName||"/"||sem:uuid-string() || ".xml"
  let $_ :=
  xdmp:document-insert($uri,
  <wf:process>
    <wf:data>{$data}</wf:data>
    <wf:attachments>{$attachments}</wf:attachments>
    <wf:audit-trail></wf:audit-trail>
    <wf:metrics></wf:metrics>
  </wf:process>,
  xdmp:default-permissions(),
  (xdmp:default-collections(),"http://marklogic.com/workflow/processes")
  )
  return $uri
}

(:
 : This module performs process data document update functions via a high level abstraction.
 :)

declare function m:complete($processUri as xs:string,$transition as node(),$stateOverride as xs:anyUri) as empty-sequence() {
  (: Fetch process model doc properties and Update completion time :)
  let $_ := m:metric($processUri,$transition/p:state/text(),xdmp:document-get-properties($processUri,xs:QName("wf:start")),fn:true())
  (: Add audit event :)
  let $_ := m:audit($processUri,$transition/p:state/text(),"ProcessEngine","Completed step",())
  return
    (: Call CPF Success with next state :)
    cpf:success($processUri,$transition,$stateOverride)
}

declare function m:failure($processUri as xs:string,$transition as node(),$failureReason as xs:string,$detail as element()*) as empty-sequence() {
  m:audit($processUri,$transition/p:state/text(),"Exception",$failureReason,$detail)
  ,
  cpf:failure($processUri,$transition,$failureReason)
}

declare function m:audit($processUri as xs:string,$state as xs:string,$eventCategory as xs:string,$description as xs:string,$detail as element()*) as empty-sequence() {
  (: Perform append operation on process document's audit element :)
  xdmp:node-insert-child(fn:doc($processUri)/wf:process/wf:audit-trail,
    m:audit-create($processUri,$state,$eventCategory,$description,$detail)
  )
}

declare function m:audit-create($processUri as xs:string,$state as xs:string,$eventCategory as xs:string,$description as xs:string,$detail as element()*) as element(wf:audit) {
  <wf:audit><wf:when>{fn:current-dateTime()}</wf:when><wf:category>{$eventCategory}</wf:category><wf:state>{$state}</wf:state><wf:description>{$description}</wf:description><wf:detail>{$detail}</wf:detail></wf:audit>
}

declare function m:metric($processUri as xs:string,$state as xs:string,$start as xs:dateTime,$completion as xs:dateTime,$success as xs:boolean) as empty-sequence() {
  (: Append metric event to internal metrics element :)
  xdmp:node-insert-child(fn:doc($processUri)/wf:process/wf:metrics,
    <wf:metric><wf:state>{$state}</wf:state><wf:start>{$start}</wf:start><wf:finish>{$completion}</wf:finish>
    <wf:duration>{fn:subtract-dateTimes-yielding-dayTimeDuration($completion,$start)}</wf:duration>
    <wf:success>{$success}</wf:success></wf:metric>
  )
}

declare function m:evaluate($processUri as xs:string,$namespaces as xs:string*,$xpath as xs:string) as xs:boolean {
  (: TODO handle version 8 javascript conditions :)
  let $ns :=
    for $namespace in $namespaces
    return ($namespace/@short/text(),$namespace/@long/text())
  return
    xdmp:with-namespaces($ns, xdmp:unpath($xpath))
}
