

See also the [Modelling Overview](MODELLING.md) for the REST API to install a MarkLogic workflow process model.


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

- DONE PUT /v1/resources/process - starts a new instance of a workflow
- DONE GET /v1/resources/process - Fetches the current process status, and optionally the current process step definition and data (allows a human step to be rendered)
- DONE POST /v1/resources/process - Completes a human process step and provides data to map to the step. Optionally also used to kick a process from an admin interface.
- TODO DELETE /v1/resources/process - Kills a process instance
- DONE GET /v1/resources/processinbox - Fetches the currently logged in user's work inbox (any human steps assigned to the current user) - summary level info only
- DONE GET /v1/resources/processqueue - Fetches a list of, or human process steps assigned to, shared workflow work stacks - DO NOT IMPLEMENT use options on processinbox instead
- TODO POST /v1/resources/processqueue - Used to lock a process instance for a particular user, or remove a lock - DO NOT IMPLEMENT use options on processinbox instead
- TEST GET /v1/resources/processsearch - Search API compatible interface that restricts results to process instances

- TEST GET /v1/resources/processengine - Fetches the currently executing processes and their status, and general CPF running information, and installed processes
- TEST DELETE /v1/resources/processengine - Stops all MarkLogic Workflow (but NOT all CPF) processes, moving them by force to the 'killed' state
