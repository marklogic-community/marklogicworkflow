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

Completed Sat 18 Apr 2015 14:30 BST by Adam Fowler

- DONE BPMN2: generic blank task
- DONE BPMN2: user task -> aka human step
- DONE BPMN2: exclusive gateway -> Decision point with one outcome, multiple options
- DONE Evaluation: Support for /xpath/path to process model data
- DONE Evaluation: Support for fn:not(fn:empty(/xpath/evaluation)) style boolean evaluation for true/false conditions in BPMN2 model
- DONE Evaluation: Support for fn:doc(/process/attachments/attachment[@name="default"]/uri/text())/some/path/to/property style evaluation
- DONE Evaluation: replace $processData or $wf:process with fn:doc($processUri) everywhere in xpath expression
- DONE can use fn:current-dateTime - Evaluation: Support for 'now' date time assignment to variable
- DONE Tools: Process Data model XSD (for modeler import)
- DONE Tools: Eclipse BPMN 2 Modeler Palette and Process diagram support, including new diagram creation for MarkLogic
- DONE Start process using an Alert (content subscription)
- DONE REST API: Basic process initiation, update and tracking methods
 - DONE processmodel.xqy
  - DONE PUT create and publish process model, accepting BPMN2 content type .bpmn2, and to update process model without publishing
  - DONE GET to fetch process model
  - DONE POST to publish process model
 - DONE process.xqy
  - DONE PUT create instance of a process (starts a process)
  - DONE POST complete a human task
  - DONE GET fetch the current state of a business process
 - DONE processsubscription.xqy
  - DONE PUT create a process subscription (alert) to create a new process instance (creating a content doc creates a process doc with an initiating attachment)
 - DONE processinbox.xqy
 - DONE processqueue.xqy
- DONE BPMN2: send task -> 1 of 2: send Email (Implemented as an example message driven task)
- DONE Test scripts for automating install, create, get, update, complete via REST API
- DONE Bug: Change process model URI folder to include major and minor - else doing process doc update may run new pipeline instead of old one
- DONE Bug: Multiple wf:status properties on in process process, complete and running
- DONE basic documentation for supported step types and their configuration (STEPS.md)
- DONE Scripting - change $wf:process/ replacement to $wf:process external variable declaration (much less buggy to implement)

## All future sprints in GitHub

Sprints are now modelled as Milestones (Sprint-00x) in GitHub. Go to the
[issues page](http://github.com/marklogic-community/marklogicworkflow/issues) for details.
