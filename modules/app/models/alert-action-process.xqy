(:
 : An alert action that allows a MarkLogic Workflow process to be subscribed to the creation of a particular document.
 : Implemented as an alert to provide as much flexibility as possible.
 :
 : In future will be expanded with more support for data mappings.
:)

xquery version "1.0-ml";

import module namespace alert = "http://marklogic.com/xdmp/alert" at "/MarkLogic/alert.xqy";
declare namespace wf = "http://marklogic.com/workflow";
import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";

import module namespace wfu="http://marklogic.com/workflow-util" at "/app/models/workflow-util.xqy";

declare variable $alert:config-uri as xs:string external;
declare variable $alert:doc as node() external;
declare variable $alert:rule as element(alert:rule) external;
declare variable $alert:action as element(alert:action) external;

(: Create a process instance for this document :)

(: Find appropriate process from alert action option :)
let $procname := $alert-action/alert:options/wf:process-name/text()
return
  wfu:create($procname,$alert:doc/element(),
    <attachment name="InitiatingAttachment" cardinality="1">
      <uri>{fn:base-uri($alert:doc)}</uri>
    </attachment>
  )

(:)
  xdmp:document-insert($procname || "/" || sem:uuid-string() || ".xml",
   <process xmlns="http://marklogic.com/workflow/process">
    <data>
    {
      (: TODO check config for mappings options - rather than map entire document in:)
      $alert:doc/element()
    }
    </data>
    <attachments>
      <attachment name="InitiatingAttachment" cardinality="1">
        <uri>{fn:base-uri($alert:doc)}</uri>
      </attachment>
    </attachments>
   </process>,
  xdmp:default-permissions(),
  (xdmp:default-collections(),"http://marklogic.com/workflow/processes")
  )
:)
