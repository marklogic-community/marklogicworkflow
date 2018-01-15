MarkLogic Workflow consists of several pieces

- Modeling CPF and BPMN2 flows
- Importing BPMN2 models for execution
- BPMN2 Workflow extensions on top of CPF
- Workflow REST API to build apps on MarkLogic Workflow

## Modeling CPF and BPMN2 flows

Rather than develop a custom modeling tool, MarkLogic Workflow makes use of the BPMN2 XML standard. This allows tools
such as Eclipse BPMN2 Modeler to create standard BPMN2 files that can be executed by MarkLogic Workflow.

As part of this project CPF specific BPMN2 'Activity' types are being added to Eclipse BPMN2 modeler. A 'MarkLogic Workflow'
mode is also being added to the modeler to restrict BPMN2 activities to those supported for import by MarkLogic Workflow.
Two models will be supported - the standard Process model and a custom CPF process model (for traditional CPF pipeline modelling).

## Importing BPMN2 models for execution

A standard CPF pipeline is represented as a BPMN2 model with Activity types restricted to only CPF states and actions.
This allows the current CPF models to be created in BPMN2. All OOTB CPF actions will be supported, including samples.

BPMN2 standard models, with some reservations, will also be supported. This aims to create a content document independent
standard workflow capability layered on top of CPF. This will support multiple parallel processes, human processing steps,
decision points, and other BPMN2 workflow concepts.

A REST API endpoint will be developed to allow a BPMN2 model to be stored - with support for major (published) and
minor (in development) versions. The importer will take a BPMN2 model major version and convert its 'Activities' to CPF
states and actions.

## BPMN2 workflow extensions on top of CPF

In order to break the link between a single initiating document and a workflow's execution a separate process data document
will be used as the CPF document. This will have its own data variables area custom to the process, and will have
associated documents linked as 'attachments' (basically data items referring to their URI).

This also allows a single human step to require that multiple attachments (E.g. eforms or uploads) are added before
completion of the human step can occur. This is a required function from UK customers.

CPF also does not support the concept of parallel execution. To support this sub process documents will be needed, and
the BPMN2 importer will in fact create multiple CPF pipelines for a single BPMN2 process in order to facilitate
parallelism. (And prevent concurrent update exceptions in CPF).

Adding support for all functionality in BPMN2 and the above human steps and parallelism necessarily means we have
to create a lot of custom CPF actions. It also means we have to add additional 'workflow' state properties to the
process data document's properties fragment, alongside the standard CPF state properties.

[Also see this page for further information on how Workflow is implemented with CPF](WEEDS.md)

## Workflow REST API to build apps on MarkLogic Workflow

MarkLogic Workflow does not provide any UI support (other than very basic UI pages for testing). In order to interact
with MarkLogic Workflow several REST API extensions are in development. These can be used to implement UI BPM style
features like User and Shared Inboxes, human 'step processor' web pages, and Eforms linking to process steps.

[Also read the REST API doc](RESTAPI.md)

## Security

MarkLogic Workflow includes its own security privileges, roles and users.

[For information read the Security doc](SECURITY.md)

## More information

For further details on all the above, see [the design document](DESIGN.md)

## How the hell does it work?

If you're wondering how a live process works, what data is created or updated, and how MarkLogic Workflow uses CPF
in practice then check out [the process walkthrough document](PROCESS-WALKTHROUGH.md).
