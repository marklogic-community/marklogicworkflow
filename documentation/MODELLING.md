
## How to install a process model in to MarkLogic Workflow

There are many process modelling standards available, including XPDL 2, BPMN 2, and SCXML, not to mention BPEL and
properietary formats.

This project describes a generic way to convert a process model for invocation within MarkLogic, and provides a
reference implementation for SCXML.

### Modelling

A modelling tool is out of scope of this project, although creating a 'MarkLogic palette' for a process tool
would be a good idea to make modelling simple for process model creators.

The Eclipse BPMN2 modeller is a good option, with support for pluggable runtime definitions and profiles. Its relatively
easy to define a MarkLogic runtime and set of custom tasks, and hide any BPMN2 tasks that we do not support the
execution of.

To install the MarkLogic Workflow BPMN2 Eclipse modeler extension, see the [Modelling Development page](DEV-MODELER.md).

Also view the [BPMN2 specification summary document](bpmn2-spec.md)

Also take a look at the [Step documentation](STEPS.md) for information on individual steps and supported parameters.

### Importing

In future a model import User Interface (UI) could be created. This is out of scope of this project. This project
only deals with providing a workflow engine reference implementation over MarkLogic CPF. A variety of UI approaches
should be usable against this project.

A set of REST API extensions have been created to assist with saving process models in to MarkLogic, and publishing
them (activating them in CPF).

- DONE PUT /v1/resources/processmodel - Creates or create a new major-minor version of a process model. MIME type differs
- DONE GET /v1/resources/processmodel - Fetches the latest, or specified version, of a process model in its original format
- DONE POST /v1/resources/processmodel - Publishes a process model (creates a CPF pipeline, and enables it, updating the CPF directory or collection scope definition)
- TODO DELETE /v1/resources/processmodel - Removes the process model's pipeline directory or collection scope definition (so no new processes can be started. Leaves currently running processes unaffected)
- TODO GET /v1/resources/processmodelsearch - Search API compatible interface that restricts results to process model definitions

There are also a number of endpoints for managing process model assets - things like blank email templates and so on:-

- TEST PUT /v1/resources/processasset - Adss or updates a process asset at the model, model-major, or model-major-minor versions. Returns URI of asset created.
- TEST GET /v1/resources/processasset - Fetches a list of assets for a model, or those assets for a specific model version.
- TEST DELETE /v1/resources/processasset - Delete a process asset template or version. Returns URI of asset deleted.

Also see the [REST API document](RESTAPI.md)
