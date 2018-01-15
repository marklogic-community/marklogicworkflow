# Feature 4 - Supporting sub processes, loops, etc.

## How it works

1. Parent process step that can fork includes a wf:branch-definitions specification in it's pipeline state options.
1. wfu:fork called with wf:branch-definitions data and, in a single transaction, creates all sub process documents, mapping data
over, including a wf:parent URI for its parent process instance
1. wfu:fork also updates parent process instance to INPROGRESS with copy of wf:branches data in properties, ready to receive
individual sub processes' status when they are complete/abandoned/failed
1. Each sub process executes as if it were a parent process. BUT data resides in parent??? TODO
1. Upon completion, wfu:complete checks to see if we're in a sub process instance, and if so updates the parent processes'
status for the named branch's element to COMPLETE
1. wfu:complete also performs check to see if all branches in parent process are now COMPLETE, and if so, sets the
wf:currentStep status to COMPLETE (thus continuing execution of the parent process).
   - This is the same mechanism that User Task uses to restart CPF processing of a parent process

#### Implementation notes

wf:branches on parent process' properties document is a top level property, NOT under wf:currentStep. This is so that
its content is visible to wfu:complete (not deleted by wfu:completeFinally), and so available to store in the audit
record by wfu:complete.

### Things still to decide

#### Algorithm for creating pipelines

1. Separate flow analysis algorithm steps through the diagram from the start event (or other initial event), and
assigns a pipeline name to each step
1. Importer must generate for each BPMN2 step one or more (a set of) CPF pipeline states, using the pipeline name from above within the state name
 - This is basically the current import algorithm, but generating its output to a map rather than a cpf pipeline XML
1. The output is then generated as a set of pipelines with the above as output, plus standard pieces (E.g. restart status transition)
1. Domain then created with all these pipelines, plus status change pipeline

Qn: Should we create 1 domain per pipeline??? I think we will have to as else there is no way to link a specific process
(or sub process) document with a specific pipeline

Qn: Public vs. Private vs. Executable: Private processes should not be imported (they're not for implementation.) Public
processes that are tagged as executable are top level executable processes, so should be imported as such. Other public
processes can only be instantiated by top level processes. This is as per the BPMN2 specification.

As a result non top-level processes should have a name and process doc location that reflects their parent's location. If
they are 'upgraded' to 'executable' (i.e. top level) then a separate version is created at the top level URI name. This
shouldn't affect the ability to find all historic versions, but will affect the ability to start the process, or list its
model, from the REST API. (Only top level executable processes should be listed for execution).

#### Handling loops

How to model multiple instances?

- Where are loop instances specified?
  - On the step's Loop characteristic?
- How are they executed?
  - If in parallel, then we need a loop id field for each branch instances, and pass this in to subprocess along with parent URI
  - If in series, need wfu:complete to check position in loop before updating parent to COMPLETE, as we may need to go
  through another loop instance

#### Data ownership

Does each subprocess receive a copy of the parent's data, OR does it have direct (and potentially parallel) access to
that data???

#### Unknown receivers

Events/signals can be received by other processes outside of this single diagram, or indeed anywhere in this diagram.
How do we want to model and manage firing child processes where the step itself doesn't know of the receiver?

Need two ways:-
1. If an intermediate step can receive signal
1. If a start event receives the signal

For the second option above, can we create a standard name across all pipelines that would allow a cts:search to be
used to find the pipelines (current executable version only) which define an initial state that matches this signal?

For the first option above we can simply search for all INPROGRESS process instances where the event/signal definition
matches this instance's settings. Use cts:search.

VALIDATION REQUIRED

## When a Fork can happen

Any time there needs to be parallel processing. Examples include:-

- DONE Parallel Gateway with one or more potential routes
- Invoke sub process (for separation reasons and ease of importing) - may not actually run in parallel (but MAY according to BPMN2 spec)
- Where a step has one next route, but also fires an event or signal (but not a message - they are directed and modelled as content)
- Any time an event or signal is fired (as there may be multiple receivers)

## From the spec

The following is from the specification for BPMN2 which affects how process engines are expected to execute process models.

The spec is in THIS REPO at /documentation/bpmn2omg/formal-11-01-03.pdf .

### 10.5.1 Sequence Flow Considerations
Note – Although the shape of a Gateway is a diamond, it is not a requirement that incoming and outgoing Sequence Flows MUST connect to the corners of the diamond. Sequence Flows can connect to any position on the boundary of the Gateway shape.
This section applies to all Gateways. Additional Sequence Flow Connection rules are specified for each type of Gateway in the sections below.
􏰀
- A Gateway MAY be a target for a Sequence Flow. It can have zero (0), one (1), or more incoming Sequence Flows.
􏰀
 - If the Gateway does not have an incoming Sequence Flow, and there is no Start Event for the Process, then the Gateway’s divergence behavior, depending on the type of Gateway (see below), SHALL be performed when the Process is instantiated.
Business Process Model and Notation, v2.0 289
  - NB THIS WILL NEED SPECIAL DETECTION IN THE IMPORTER
  - TODO not handled yet (arguably an anti-pattern anyway)

- A Gateway MAY be a source of a Sequence Flow; it can have zero, one, or more outgoing Sequence Flows.
 - FINE

􏰀- A Gateway MUST have either multiple incoming Sequence Flows or multiple outgoing Sequence Flows (i.e., it MUST merge or split the flow).
 - FINE. Mainly an editor feature - we don't actually care
 - TODO We should probably do a sanity check on having at least one outgoing sequence flow

􏰀- A Gateway with a gatewayDirection of unspecified MAY have both multiple incoming and outgoing Sequence Flows.
 - THIS WILL NEED SPECIAL DETECTION IN THE IMPORTER
 - TODO unspecified specifically not supported in the importer as of sprint-002

􏰀- A Gateway with a gatewayDirection of mixed MUST have both multiple incoming and outgoing Sequence Flows.
 - FINE Leave this up to the modelling tool

􏰀- A Gateway with a gatewayDirection of converging MUST have multiple incoming Sequence Flows, but MUST NOT have multiple outgoing Sequence Flows.
 - FINE. Entirely a modelling issue. Importer is clever enough (generally) to not balk at such a malformed step configuration.

􏰀- A Gateway with a gatewayDirection of diverging MUST have multiple outgoing Sequence Flows, but MUST NOT have multiple incoming Sequence Flows.
 - FINE. Entirely a modelling issue.

## How BPMN2 models relate to CPF pipelines and states

### Parallel Gateways

How the basic, parallel gateways work. These involve ALL routes being executed, in parallel, and rendezvous happening
before the flow continues in the process.

NB A contained route may contain other parallel flows via two more parallel gateways.

#### Parallel Gateway Step for diverging


<bpmn2:sequenceFlow id="SequenceFlow_1" sourceRef="StartEvent_1" targetRef="ParallelGateway_1"/>
<bpmn2:parallelGateway id="ParallelGateway_1" name="ForkStep" gatewayDirection="Diverging">
  <bpmn2:incoming>SequenceFlow_1</bpmn2:incoming>
  <bpmn2:outgoing>SequenceFlow_3</bpmn2:outgoing>
  <bpmn2:outgoing>SequenceFlow_4</bpmn2:outgoing>
</bpmn2:parallelGateway>

#### Task within one of the contained flows


<bpmn2:task id="Task_1" name="Task 1">
  <bpmn2:incoming>SequenceFlow_3</bpmn2:incoming>
  <bpmn2:outgoing>SequenceFlow_5</bpmn2:outgoing>
</bpmn2:task>
<bpmn2:task id="Task_2" name="Task 2">
  <bpmn2:incoming>SequenceFlow_4</bpmn2:incoming>
  <bpmn2:outgoing>SequenceFlow_6</bpmn2:outgoing>
</bpmn2:task>
<bpmn2:sequenceFlow id="SequenceFlow_3" sourceRef="ParallelGateway_1" targetRef="Task_1"/>
<bpmn2:sequenceFlow id="SequenceFlow_4" sourceRef="ParallelGateway_1" targetRef="Task_2"/>
<bpmn2:sequenceFlow id="SequenceFlow_5" sourceRef="Task_1" targetRef="ParallelGateway_2"/>
<bpmn2:sequenceFlow id="SequenceFlow_6" sourceRef="Task_2" targetRef="ParallelGateway_2"/>

#### Parallel Gateway Step for converging


<bpmn2:parallelGateway id="ParallelGateway_2" name="RendezvousStep" gatewayDirection="Converging">
  <bpmn2:incoming>SequenceFlow_5</bpmn2:incoming>
  <bpmn2:incoming>SequenceFlow_6</bpmn2:incoming>
  <bpmn2:outgoing>SequenceFlow_2</bpmn2:outgoing>
</bpmn2:parallelGateway>
<bpmn2:sequenceFlow id="SequenceFlow_2" sourceRef="ParallelGateway_2" targetRef="EndEvent_1"/>
