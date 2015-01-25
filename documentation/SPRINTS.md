This PoC development will occur in small sprints until a useful PoC system is available to cover most workflow needs.

## Customer requirements

- UK-D-F
 - Random number set to variable
 - Evaluation of random number variable <= 0.10 (10% change this route chosen) to affect exclusive gateway
 - Resubmit notification sent
 - Await for new document version (could be implemented at start of same process)
 - Create count variable, update, and evaluate (max number of loops until success, or give up)
 - Nice to have: Search based on some hard coded and some data driven criteria, add as attachments, count attachments and route based on that number
 - Find document related to data (provider info), get percentage for original routing from this. Also set this percentage
 - Email notification
- UK-D-E
 - Create Attachment step - one or more attachments must be set in order to proceed (E.g. required forms at this step)
 - SLA timer and routing on failure
 - Email notification
- UK-D-I

## Sprint 1 - Basic workflow

- DONE BPMN2: generic blank task
- BPMN2: user task -> aka human step
- DONE BPMN2: exclusive gateway -> Decision point with one outcome, multiple options
- DONE Evaluation: Support for /xpath/path to process model data
- DONE Evaluation: Support for fn:not(fn:empty(/xpath/evaluation)) style boolean evaluation for true/false conditions in BPMN2 model
- TEST Evaluation: Support for fn:doc(/process/attachments/attachment[@name="default"])/some/path/to/property style evaluation
- Evauation: Support for 'now' date time assignment to variable
- Activity: Set process variable activity with multiple from and to (simple XPath evaluation)
- Evaluation: Support for (/some/path/one,/some/path/two)[1] style evaluation for set task
- TEST Tools: Process Data model XSD (for modeler import)
- Tools: Eclipse BPMN 2 Modeler Palette and Process diagram support, including new diagram creation for MarkLogic
- BPMN2: loop characteristic available in activity definitions rather than as separate process step
- DEFERRED UI: Ridiculously basic HTML widget in MLJS for rendering step and choosing action (for ease of testing)

## Sprint 2 - CPF modelling

- MarkLogic specific Activity types for pure CPF processes
 - CPF Action (module, options)
 - CPF State change event throw and receive
- Domain specification support within modelling diagram
- Direct import and set up
- Activity: BPMN2 step for non-CPF diagrams to change state on an Attachment, thus invoking a CPF pipeline
- Tools: Eclipse modeler updated with CPF Diagram and steps

## Sprint 3 - Process Orchestration

- BPMN2: ad hoc sub process
- BPMN2: call activity
- BPMN2: terminate current process
- BPMN2: call activity (process or global task)
- BPMN2: parallel gateway -> fork to or synchronise from all flow paths
- BPMN2: complex gateway -> E.g. 3 of 5 incoming routes required in order to activate gateway
- CPF: Invoke CPF pipeline
- BPMN2: service task -> invoke service and process response
- Update Eclipse Modeler palette

## Sprint 4 - Event driven

- BPMN2: error event
- BPMN2: escalation event
- BPMN2: Timer (duration or specific date time) (and timeout for escalation??? Is this supported in OOTB BPMN2?)
- BPMN2: sub-process -> can be triggered by event rather than direct calling
- BPMN2: event based gateway
- Update Eclipse Modeler palette

## Sprint 5 - MarkLogic functionality

- MarkLogic: Search, results populate attachment array field, configurable limit
- MarkLogic: Set document element value (XPath)
- MarkLogic: Get document element value (XPath)

### BPMN2 out of scope for PoC implementation

The following are other common BPMN2 elements that won't be implemented

- BPMN2: Task
- BPMN2: Manual Task -> External (E.g. paper based) task to process engine
- BPMN2: Script task
- BPMN2: Business rule task -> Requires BRE implementation
- BPMN2: receive task -> Requires service endpoint implementation
- BPMN2: send task -> invoke web service as fire and forget
- BPMN2: transaction -> commit or cancel transaction
- BPMN2: gateway -> all can fork or rendezvous processes
- BPMN2: message event
- BPMN2: signal event
- BPMN2: pluggable data store implementations
- BPMN2: can import XSD, WSDL, BPMN2 for types and services
- BPMN2: input and output sets (overloaded activities like methods)
