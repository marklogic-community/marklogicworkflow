This document walks you through a process document and it's properties fragment to show how MarkLogic Workflow
works internally.

## Document Instantiation

In many circumstances a process will be initiated by a new or changed document. Alerting is used rather than CPF
domains for this.

### Document creation

The document is inserted as normal, with no specific settings or additional workflow specific properties. The document
never 'knows' it has a process associated with it. Let us say that this document has the uri /some/doc.xml

### Document Alert

If the document matches an alerting domain with a 'Workflow Initiation' alert action, the following will happen:-

1. The action (/modules/app/models/alert-action-process.xqy) will be activated with $alert:doc set to the new or
modified document
1. This fetches the process name (E.g. myprocess__1__0) from the alert:config parameter
1. wfu:create is called with an attachment like the following added to it:
```xml
<wf:attachment name="InitiatingAttachment" uri="/some/doc.xml" cardinality="1"/>
```
1. This creates a process document in the appropriate folder (ready for a workflow CPF domain, as below) with the
initial XML of the following, with the URI /workflow/processes/myprocess__1__0/SOMEUUID-CURRENTDATETIME.xml:-
```xml
<wf:process id="SOMEUUID-CURRENTDATETIME">
  <wf:data>
  </wf:data>
  <wf:attachments>
    <wf:attachment name="InitiatingAttachment" uri="/some/doc.xml" cardinality="1"/>
    <wf:attachment name="PDFRendering" uri="" cardinality="1"/> <!-- optional attachment example -->
  </wf:attachments>
  <wf:audit-trail>
  </wf:audit-trail>
  <wf:metrics>
  </wf:metrics>
  <wf:process-definition-name>myprocess__1__0</wf:process-definition-name>
</wf:process>
```

This is added to the http://marklogic.com/workflow/processes collection. At this point there are no MarkLogic workflow
specific properties created on the document's properties fragment.

## Process Initiation

The workflow importer will generate one or more CPF pipelines and attach them to one or more domains, with one
master domain for the root process.

### CPF Domain

Any process documents created under the /workflow/processes/myprocess__1__0 folder
will cause this master domain to fire, and run the master pipeline for the process model version.

### Initial State

There are several states that all MarkLogic Workflow master pipelines go through, with associated actions:-

1. http://marklogic.com/states/initial - the CPF initial state
  1. CPF creates the normal CPF properties on the PROCESS document (not the initiating attachment that fired the alert)
  1. This state has a default action of /modules/workflowengine/actions/workflowInitialSelection.xqy
  1. This step purely determines from the URI the process ID myprocess__1__0 and thus that the next state is the one named below
    - This is done due to how sub processes are implemented, to ensure the correct pipeline is initiated as each domain Can
      have only one initial state, but many sub process 'start' states (one per fork - see parallel gateway, below)
  1. wfu:complete is called, which puts a metric and an audit entry in to the process XML, as shown below (myprocess__1__0__start)

The XML process document now looks like:-
```XML
<wf:process id="SOMEUUID-CURRENTDATETIME">
  <wf:data>
  </wf:data>
  <wf:attachments>
    <wf:attachment name="InitiatingAttachment" uri="/some/doc.xml" cardinality="1"/>
  </wf:attachments>
  <wf:audit-trail>
    <wf:audit>
      <wf:when>{fn:current-dateTime()}</wf:when>
      <wf:category>PROCESSENGINE</wf:category>
      <wf:state>http://marklogic.com/states/initial</wf:state>
      <wf:description>Completed step</wf:description>
      <wf:detail></wf:detail>
    </wf:audit>
  </wf:audit-trail>
  <wf:metrics>
    <wf:metric>
      <wf:state>http://marklogic.com/states/initial</wf:state>
      <wf:start>{$startDateTime}</wf:start>
      <wf:finish>{$completionDateTime}</wf:finish>
      <wf:duration>{$completionDateTime - $startDateTime}</wf:duration>
      <wf:success>true</wf:success>
    </wf:metric>
  </wf:metrics>
  <wf:process-definition-name>myprocess__1__0</wf:process-definition-name>
</wf:process>
```

And the XML properties fragment now looks like:-
```XML
```
TODO INCLUDE CPF PROPERTIES AS STANDARD IN THE ABOVE

### State before first step

1. http://marklogic.com/states/myprocess__1__0__start - the initial workflow state placeholder for future action-process
  1. This state has no default action (currently) and moves straight on...
  1. No audit items or metrics are added to the process document for this step as there is no code to call wfu:complete().
  1. CPF information in the properties document may be updated TODO confirm this

## Exclusive Gateway

This represents a state that can be immediately evaluated, and updates CPF state straight away on execution of its action.
The vast majority of BPMN2 steps result in a single atomic CPF state with a single action, and so the below model happens
for sendTask and other tasks that do not result in fork/rendezvous semantics.

1. http://marklogic.com/states/myprocess__1__0/ExclusiveGateway_1 - Named after the first BPMN2 step in the process model (by XML ID not name)
  1. The /modules/workflowengine/actions/exclusiveGateway.xqy action fires
  1. This takes a copy of the namespaces used by the BPMN2 processes (copied to cpf:options by the importer)
    1. Each route in the $cpf:options/wf:route element (route definitions copied by the importer) has it's condition evaluated
    1. The first condition that returns true has it's route followed, with others being ignored
    1. If no conditions return true, the default condition if specified is followed
  1. wfu:complete is called BUT includes the override for the next CPF state, which is equal to the state name for the BPMN2 step that should be executed next
    1. audit and metric log entries are made
  1. CPF continues to evaluate the next states until completion

The condition evaluation takes the XQuery condition, copied from the BPMN2 XQuery or XPath condition by the importer,
and evaluates it in a query-only transaction mode (to prevent XQuery injection attacks). This returns true or false.

In our example let us say the route is chosen that routes to a human step, as described next below.


## Human Step

CPF has no concept of human step. MarkLogic Workflow tags a process' properties with special elements to highlight the
fact we are waiting for a human action. CPF in the meantime enters the 'done' state, and stops processing.

MarkLogic Workflow's REST API is then used to manually 'complete' a step, basically changing a status property, which
in turn causes CPF to restart and move the process on.

This full, quite complex, procedure is detailed below. This is the basis for all asynchronous, out of CPF time, processing
implemented by MarkLogic Workflow.

### Condition and action

A condition uses a BPMN2 script (type XQuery or XPath) field's data to calculate a true or false value. Each route out
of an exclusive gateway will either have a condition or will be a 'defult route' - i.e. the route chosen if no other
route's condition returns true.

The condition expression is evaluated in a controlled eval that limits the expression to query only. This prevents
XQuery injection attacks inadvertantly happening. This eval has access to the $wf:process variable. This variable
points to the process instance document. Because this process instance contains transient (inside process only) and
links to attachments (URIs of documents in MarkLogic), this is the only variable required to evaluate any condition.

As an example fn:not(fn:empty($wf:process/wf:data/someemail)) evaluates whether an email address has been found within
some previous step in the process (or provided when initiating the process).

Similarly fn:doc($wf:process/wf:attachments/wf:attachment[@name = 'CustomerQuote']/uri/text())/some/document/element
returns an element from within a referenced attachment.

The Excluve Gateway action is in /modules/workflowengine/actions/exclusiveGateway.xqy . For each route from
the esclusive gateway the action evaluates each condition until one returns true. This CPF action overrides the next
step name using wfu:complete's third (optional) parameter. This is because CPF allows you to specify no next state
until an action occurs. This is the mechanism used by the exclusive gateway and all other non-human route determining
(forking) actions.

### Waiting for user action

CPF is not designed to wait for human action. Either CPF is processing states, or it is 'done'. CPF should in fact be
'done' once the userTask.xqy action is evaluated until a human's action causes processing to restart. Thus the
userTask.xqy action DOES NOT call wfu:complete but instead cpf:success. Having no next step, CPF is 'done'.

As far as MarkLogic workflow is concerned (and CPF) though, we're still in the state for the userTask. The userTask
action simply sets properties on the process' properties fragment flagging the fact this process is awaiting user action.
 These properties are what the MarkLogic Workflow REST API (and thus the wfu utility library) uses to list a particular
user, role, or queue's outstanding tasks.

### During user action (locking)

TO BE IMPLEMENTED...

When a user 'opens' a task it is anticipated that the step processor (the application UI within which you've selected a
work item to work on) will call POST /v1/resources/process specifying that the user has 'locked' the process instance.
This is pessimistic locking provided by the MarkLogic Workflow REST API, not within the MarkLogic database layer itself.

This is desirable because for public 'queues' visible by many users you don't want to have multiple people working on
the same work item. Locking is implemented through a wf:locked-by element within the properties fragment of the process.

### Saving for later

By providing different parameters to POST /v1/resources/process the user can update process data, and either free the
task for completion by another user, or leave it locked in their work basket for future completion.

### User completion

On completion the step processor should do another POST to /v1/resources/process, optionally with updated process data,
and complete the task.

Under the hood this is performed by wfa:complete-userTask found in /modules/app/models/workflow-actions.xqy. This
updates the process document's properties such that the underlying CPF implementation of the BPMN2 process continues
execution.

### Final state

Once this happens the CPF status-update status (not state) transition will occur. This in turn causes the isComplete.xqy
CPF condition to be executed. If this returns true (i.e. the user has finished the step completely) then the process
is marked as complete, wfu:complete is called by genericComplete.xqy action, and the next state specified in the
STEPNAME__complete CPF state's cpf:options is transitioned to.

Thus all human (or asynchronous generally) BPMN2 step has two CPF states STEPNAME and STEPNAME__complete. This is
required because of how CPF performs conditions then evaluations based on document status change events.

## Parallel Gateway

Parallel gateways, inclusive gateways, sub processes, or invoke steps (that execute 'public' top level BPMN2 processes) all have the
potential to need multiple parallel executions of a set of steps to occur. They then require rendezvous (waiting for all
  parallel forks to complete) before execution continues.

CPF does not support the concept of asynchronous execution. A single document (in our case a process document) can only
be managed by a single CPF pipeline. This is because CPF is controlled through a single set of properties in the properties
fragment of a document. A single set means only a single CPF pipeline at a time.

To get around this every time the BPMN2 importer sees the potential for parallel execution it will generate a parent
fork action and rendezvous await action. It will then generate a new pipeline for each route with the name of the fork
step name and route within it's name. This also occurs for any contained parallel routes, to any depth.

Thus a single BPMN2 process always generates one or more pipelines in CPF. One for the parent process, and one for
every route after every fork (parallel gateway or similar) step.

These subprocesses are modelled using the exact same process document structure, albeit created in their own
sub folders in MarkLogic. These sub processes contain a reference to their parent process URI and the forkid (determined
  at runtime). This allows wfu:complete to update the parent processes' rendezvous status tracking for each sub process.

### Fork

A generic action /modules/workflowengine/actions/fork.xqy controls forking for every type of parent step. The only
difference is the parameters passed in to the configuration of the fork and rendezvous actions. For example a parallel
gateway always waits for all routes to complete, whereas an inclusive gateway needs to determine at runtime the number
of routes whose conditions returns true before it knows how many sub-processes to wait for.

### Processing

Each sub process pipeline is evaluated in the same way as if it were a main process. There is no real difference at all.

### Rendezvous

wfu:complete when called on the last state in the child process will call wfu:updateStatusInParent. This function
updates the status of the sub process' tracking element in its parent process document. This include final status
information (complete or failed) and other information like completion time.

Because the parent process document has been updated, the CPF status changed status transition is invoked, and in
turn the hasRendezvoused action in /modules/workflowengine/conditions/hasRendezvoused.xqy is invoked.

If the status tracking elements are all not INPROGRESS, then this condition returns true. This in turn causes the
parent process' state to transition to the next state for the BPMN2 process.

## Completion

wfu:complete is called at the end of every CPF action that represents the final CPF action for a BPMN2 process step.
CPF then executes the next state transition, which will have a corresponding MarkLogic Workflow CPF action, which in
turn calls wfu:complete itself. This continues until an endEvent is encountered.

### End Event

The /modules/workflowengine/actions/endEvent.xqy action adds the wf:end timestamp property to the process document's
properties fragment, and then calls wfu:complete. This in turn logs completion audit and metrics (time taken) information
to the process document. It also updates any parent process' status tracking element if the current process is a sub process.

### Final state

The wfu:complete utility library function removes intermediate wf:currentStep properties from the properties fragment
of the process document. Thus no ML Workflow property, other than wf:end, will exist after completion of the higher
level 'workflow' (i.e. the whole BPMN2 process, that may have been implemented as multiple CPF pipelines and process and
  sub process documents).

CPF will in turn transition to the 'done' state. This along with other cpf properties will still exist in the properties
fragment of the process document upon completion.

All audit information, final transient (process variable) state, attachment links, and metric information (how long each
  workflow state took to execute) is logged in the process document itself. This remains after the process is complete
in order to provide statistics and an audit trail.

Currently there is no process roundtrip re-engineering supported, but having the metrics and audit information should
allow at least a technical evaluation of a process' performance to be done. Indexing these elements may even in future
allow the use of MarkLogic search and co-occurence to provide performance dashboards for past and in-process workflows.
This may be useful where customers have a Business Activity Monitoring (BAM) solution, such as IBM Cognos Now!.
