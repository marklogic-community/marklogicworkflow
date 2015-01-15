A quick and dirty basic SCXML to CPF pipeline conversion project, with test scenarios.

## Why? Just... Why!?!

This project aims to provide a new useful way to define CPF Pipelines. This means providing a way to model CPF pipelines
and then take those models to generate a pipeline. Rather than create a custom modelling tool just for CPF, it is easier
to use one of the many process model formats and existing tools, and provide a palette of MarkLogic specific actions for
these tools.

This functionality could also be used by MarkLogic customers to implement extended workflow functionality.

### What this project is

The project aims to provide just enough functionality to provide a 'content centric workflow' capability within MarkLogic
Server, and no more. Hence the moniker 'MarkLogic Workflow'.

Primary aims:-
- Provide a way to configure CPF pipelines on MarkLogic
- Provide a set of actions that perform high level processing logic common to modelling formats (if/then, switch/case, fork/rendezvous, add audit log)
- Provide an easy way to configure a specific process model instance to be executed when a new document enters MarkLogic
- Incorporate existing MarkLogic pipeline actions without any code changes (E.g. start the document conversion pipeline for a specified document)

Note the internal classes refer to the MarkLogic Workflow fature set as the 'process engine'. This is purely the name
for the modelling and execution part of MarkLogic Workflow.

### What this project isn't

This project does not aim to provide a full fledged end to end BPM Suite (BPMS) incorporating process modelling, simulation,
business activity monitoring, workforce management, or full round trip (six sigma style) process re-engineering.

This project also does not try and provide any user interface at all over the workflow engine.

This project is NOT a 'process engine' or 'business process management engine' or 'BPEL engine' or 'BPM Suite'.

This project specifically does not provide any actions to affect external systems, other than the possibility of
invoking a SOAP or REST service (which are anyway primarily aimed at invoking systems that enrich documents or translate
text and such).

### The future

It is possible this project may extend the workflow data model in order to add 'Case folder' and 'case management'
actions that may be of use when implementing a case management system over MarkLogic Workflow.

KT is also looking at plugging an E-forms tool in to MarkLogic Server. This brings the tantilising prospect of a way
to configure content centric workflow applications with a user interface over documents in MarkLogic Server.

This system could then be used for pre-sales demonstrations of complex information management scenarios beyond the usual
simple 'add document' and 'search for document' capabilities of MarkLogic Server.






## How to install a process model in to MarkLogic Workflow

There are many process modelling standards available, including XPDL 2, BPMN 2, and SCXML, not to mention BPEL and
properietary formats.

This project describes a generic way to convert a process model for invocation within MarkLogic, and provides a
reference implementation for SCXML.

### Modelling

A modelling tool is out of scope of this project, although creating a 'MarkLogic palette' for a process tool
would be a good idea to make modelling simple for process model creators.

TODO: What is the modelling tool we've used before that is open source?

### Importing

In future a model import User Interface (UI) could be created. This is out of scope of this project. This project
only deals with providing a workflow engine reference implementation over MarkLogic CPF. A variety of UI approaches
should be usable against this project.

A set of REST API extensions have been created to assist with saving process models in to MarkLogic, and publishing
them (activating them in CPF).

- PUT /v1/resource/processmodel - Creates or create a new major-minor version of a process model. MIME type differs
- GET /v1/resource/processmodel - Fetches the latest, or specified version, of a process model in its original format
- POST /v1/sresource/processmodel - Publishes a process model (creates a CPF pipeline, and enables it, updating the CPF directory or collection scope definition)
- DELETE /v1/resource/processmodel - Removes the process model's pipeline directory or collection scope definition (so no new processes can be started. Leaves currently running processes unaffected)
- GET /v1/resource/processmodelsearch - Search API compatible interface that restricts results to process model definitions






## How the workflow engine works

The workflow engine is built on top of MarkLogic CPF and enhances this with a set of standard actions for common
functions supported by process modelling tools.

There are two methods to start a workflow.

### Manual initiation

1. REST API endpoint called to start workflow
2. Workflow started

### Content initiated

1. Document added to MarkLogic
2. Start Workflow alert (post-commit) called
3. Alert configuration used to choose published process model instance to initiate
4. Data mapped from content/properties of document in to initial process fields (if required)
5. Document added as attachment to process instance (CPFAttachment field - URI of doc)
6. Workflow started

### What happens when a workflow starts

1. A Process Instance XML document is created
2. The relevant workflow engine CPF pipeline is invoked over this process instance document
3. State transitions perform actions, and update this process state document

Note: The process is NOT started on the original document attachment, but rather over the process instance document.
This allows document properties to remain unchanged, and permits multiple workflow instances to execute in parallel with
the same document 'attachment'.

### Running a process

The process goes through several states. Below is an example of a simple process (see data/examples/scxml/two-sample-transitions.xml):-

1. CPF pipeline enters initial state
2. State automatically transitioned to CPF standard 'initial' implementation state from process model - 'Open'
3. No actions performed as the state doesn't define any
4. State transitioned to next state - 'In progress'
5. No actions performed as the state doesn't define any
6. State transitioned to next state - 'Closed'
7. State transitioned to CPF standard 'done' state
8. CPF closes the process (marked as complete)

In future the initial state could be used to perform any initial actions defined in the original process model.

The final state success action in future could also be modified to, for example, delete the complete process document.

A standard action should be created to update the Workflow log event record.
E.g. for process administration and debugging purposes, or for a 'process history' tab.

### REST API endpoints

Various endpoints have been created to initiate new process instances and manage the process engine.

- PUT /v1/resource/process - starts a new instance of a workflow
- GET /v1/resource/process - Fetches the current process status, and optionally the current process step definition and data (allows a human step to be rendered)
- POST /v1/resource/process - Completes a human process step and provides data to map to the step. Optionally also used to kick a process from an admin interface.
- DELETE /v1/resource/process - Kills a process instance
- GET /v1/resource/processinbox - Fetches the currently logged in user's work inbox (any human steps assigned to the current user) - summary level info only
- GET /v1/resource/processstack - Fetches a list of, or human process steps assigned to, shared workflow work stacks
- POST /v1/resource/processstack - Used to lock a process instance for a particular user, or remove a lock
- GET /v1/resource/processsearch - Search API compatible interface that restricts results to process instances

- GET /v1/resource/processengine - Fetches the currently executing processes and their status, and general CPF running information, and installed processes
- DELETE /v1/resource/processengine - Stops all MarkLogic Workflow (but NOT all CPF) processes, moving them by force to the 'killed' state
