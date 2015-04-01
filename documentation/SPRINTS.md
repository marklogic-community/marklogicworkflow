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
 - Assigning tasks to MarkLogic roles
 - Assigning Role dynamically via XQuery expression
- UK-D-I

## Theoretical requirements

These are requirements we believe will be useful, but have no customer use cases linked to them at present (and so they are out of scope):-

- De-duplication - Hashing of binary content of a document to determine uniqueness. Performing automated or human routed
steps if a duplicate is found. Requires search (by property hash AND not (same uri as starting doc)
- Content publishing approval - Also implies versioning get/set support
- Content deletion timeout review - with option for placing holds on content to prevent deletion
- Complex case synchronisation - Proceed in process when several linked items of required content are present. Also implies firing a new process that fires a content arrived event that is picked up by another (or multiple) process instances waiting on that content
- Case management - creation of 'case' object, linking of content (attachments live during time of process, case filing exists longer after), setting case object visibility/security
- Tasking - create human task definition, pass to other users/groups (including via QBFR to other systems, or external BPM systems)
- Collaboration - ad-hoc communities of interest working on the same case, including external invitees to access that compartment of information

## Sprint 1 - Basic workflow

- DONE BPMN2: generic blank task
- DONE BPMN2: user task -> aka human step
- DONE BPMN2: exclusive gateway -> Decision point with one outcome, multiple options
- DONE Evaluation: Support for /xpath/path to process model data
- DONE Evaluation: Support for fn:not(fn:empty(/xpath/evaluation)) style boolean evaluation for true/false conditions in BPMN2 model
- DONE Evaluation: Support for fn:doc(/process/attachments/attachment[@name="default"]/uri/text())/some/path/to/property style evaluation
- DONE Evaluation: replace $processData or $wf:process with fn:doc($processUri) everywhere in xpath expression
- DONE can use fn:current-dateTime - Evaluation: Support for 'now' date time assignment to variable
- Activity: Set process variable activity with multiple from and to (simple XPath evaluation)
 - See if there is an equivalent BPMN2 method - may just be a variable assignment on each step instead
 - Create import step for this BPMN2 method
 - Create CPF step to represent this
- TEST Evaluation: Support for (/some/path/one,/some/path/two)[1] style evaluation for set task
- DONE Tools: Process Data model XSD (for modeler import)
- IN PROGRESS Tools: Eclipse BPMN 2 Modeler Palette and Process diagram support, including new diagram creation for MarkLogic
- DEFERRED UI: Ridiculously basic HTML widget in MLJS for rendering step and choosing action (for ease of testing)
- TEST Start process using an Alert (content subscription)
- TEST REST API: Basic process initiation, update and tracking methods
 - DONE processmodel.xqy
  - DONE PUT create and publish process model, accepting BPMN2 content type .bpmn2, and to update process model without publishing
  - DONE GET to fetch process model
  - DONE POST to publish process model
 - DONE process.xqy
  - DONE PUT create instance of a process (starts a process)
  - DONE POST complete a human task
  - DONE GET fetch the current state of a business process
 - TEST processsubscription.xqy
  - TEST PUT create a process subscription (alert) to create a new process instance (creating a content doc creates a process doc with an initiating attachment)
 - DONE processinbox.xqy
 - DONE processqueue.xqy
 - TEST support for roles (processroleinbox.xqy) on user tasks (For BD)
- DONE Test scripts for automating install, create, get, update, complete via REST API
- DONE Bug: Change process model URI folder to include major and minor - else doing process doc update may run new pipeline instead of old one
- DONE Bug: Multiple wf:status properties on in process process, complete and running
- BPMN2 specification test process models modified and tested to MarkLogic executable standard
 - Basic
  - Incident Management Level 1
  - Incident Management Account Manager Only
  - Incident Management Process Engine only
- DONE basic documentation for supported step types and their configuration (STEPS.md)

## Sprint 2 - Process Orchestration

- BPMN2: loop characteristic available in activity definitions rather than as separate process step
- BPMN2: ad hoc sub process
- BPMN2: call activity
- BPMN2: terminate current process
- BPMN2: call activity (process or global task)
- BPMN2: parallel gateway -> fork to or synchronise from all flow paths
- BPMN2: complex gateway -> E.g. 3 of 5 incoming routes required in order to activate gateway
- CPF: Invoke CPF pipeline
- BPMN2: service task -> invoke service and process response
- Update Eclipse Modeler palette
- Enterprise features
 - Set security as relevant to the process document at each step in the process
 - Allow a set security permissions on documents feature
 - Ensure installation creates relevant roles and permission sets
- BPMN2 specification test process models modified and tested to MarkLogic executable standard
 - Advanced
  - Collapsed sub process
  - Correlation example seller
  - email voting 2
  - expanded subprocess
  - laneset
  - pool
  - Process
  - Procurement Processes with Error Handling - Stencil Trosotech 2 pages
  - Travel Booking
  - triso - Hardware Retailer v2
  - Triso - Order process for pizza v4
 - Extended
  - Call activity
  - Nobel prize process

## Sprint 3 - Event driven

- BPMN2: error event
- BPMN2: escalation event
- BPMN2: Timer (duration or specific date time) (and timeout for escalation??? Is this supported in OOTB BPMN2?)
- BPMN2: sub-process -> can be triggered by event rather than direct calling
- BPMN2: event based gateway
- Update Eclipse Modeler palette

## Sprint 4 - MarkLogic functionality

- MarkLogic: Search, results populate attachment array field, configurable limit
- MarkLogic: Set document element value (XPath)
- MarkLogic: Get document element value (XPath)


## Sprint 5 - CPF modelling

- MarkLogic specific Activity types for pure CPF processes
 - CPF Action (module, options)
 - CPF State change event throw and receive
- Domain specification support within modelling diagram
- Direct import and set up
- Activity: BPMN2 step for non-CPF diagrams to change state on an Attachment, thus invoking a CPF pipeline
- Tools: Eclipse modeler updated with CPF Diagram and steps

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
