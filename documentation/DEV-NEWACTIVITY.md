This document details how a developer should implement a new BPMN2 Activity type.

## Write the activity code

You will need a CPF action with MarkLogic Workflow additions in order to implement your step type.

For a good example have a look at /modules/workflowengine/actions/startEvent.xqy .

There are several mandatory features of an activity:-

- It is implemented as a CPF action
- It must have a try-catch statement that calls wf:failure (NOT cpf:failure) when it fails
- The main body must capture the start time for the step and pass this in at the end to wf:compelte (NOT cpf:success)
- wf:complete must be called at the end

There are some optional elements:-

- If you need to override the next State (workflow step) then send the next step name as a string to wf:complete. This is needed if implementing a gateway. (route choice) (See /modules/workflowengine/actions/exclusiveGateway.xqy for an example)


## Defining a custom BPMN2 step in Eclipse BPMN2 Modeler

TODO write this section

## Out of process step completion

CPF is designed for steps to execute straight through, or wait until the content is modified before the state can
be transitioned. In Workflow an out of CPF action may need to complete a state. In order to do this, CPF must be told
that a CPF action (genericComplete.xqy) can move the state onwards. This CANNOT be done outside of a CPF action (despite
  what the MarkLogic documentation website says).

In order to do this :-
- In your initiating CPF action (E.g. userTask.xqy) set an element (/prop:properties/wf:currentStep/wf:step-status) to ENTERED
- Then something out of process happens, setting just this property to either IN PROGRESS, then eventually COMPLETE
- The restart.xqy status change action fires, spots COMPLETE, and forces CPF to the state specified in prop:properties/wf:currentStep/wf:state
- This also calls wfu:complete, which deletes prop:properties/wf:currentStep
- CPF then transitions to the new state, which is where you should have an action to run any cleanup for your out of process activity
- Also, you must call the genericComplete.xqy action, which in turn calls wfu:complete, moving on to the success state specified

NEVER call wfu:complete or wfu:completeById outside of a CPF action - only wfu:finallyComplete (as done in process POST rest api call)

## Notes on the CPF configuration of custom steps

Some things of note when creating a new step type:-

- If your step needs to wait for an external manual action (E.g. its a human task or a receive web service task) then its on-success state should be blank. (This should be set by the external process)  

## Update the BPMN2 importer code

Don't forget to update the /app/models/workflow-import.xqy code to conver the BPMN2 representation of your step to
a CPF state and link to an action. All BPMN2 custom configuration should be copied in to the CPF action's options XML element.

## Deploy your modules

./mljsadmin --install=modules

You should now be able to import a new BPMN2 model with your custom action type and execute the model successfully.

## List of needed activities

These are yet to be coded. Feel free to add them yourself and send a pull request!

BPMN2 Activities

- BPMN2: User task (human step)
- BPMN2: Ad hoc sub process
- BPMN2: call activity
- BPMN2: terminate current process
- BPMN2: call activity (process or global task)
- BPMN2: parallel gateway -> fork to or synchronise from all flow paths
- BPMN2: complex gateway -> E.g. 3 of 5 incoming routes required in order to activate gateway
- BPMN2: service task -> invoke service and process response (SOAP and HTTP REST)
- BPMN2: error event
- BPMN2: escalation event
- BPMN2: Timer (duration or specific date time) (and timeout for escalation??? Is this supported in OOTB BPMN2?)
- BPMN2: sub-process -> can be triggered by event rather than direct calling
- BPMN2: event based gateway

Additional generic

- Set process variable (support for multiple in same definition)
- Separate loop step (as opposed to having this within each and every activity type)

MarkLogic Specific

- Map variables (to/from process/attachment, support for multiples)
- Send email (SMTP message?) with optional attachments
- Attach document
- Attach search results
- Attach search
- Attach collection
- Attach folder
- Detach
- Get document element/attr (XPath)
- Set document element/attr (XPath)
- Append child element
- Get property
- Set property
- Invoke CPF pipeline for attachment
- Delete document (and remove from attachment)
- Insert document (from attachment and content with mime type)
- Set document security
- Remove role access
- Add role access
- Set role access
- Generate content MD5 hash
- Validate content MD5 hash
- Generate property (non CPF or WF) property hash
- Validate property (non CPF or WF) property hash
- Mark as duplicate (and hide access)
- Create alert
- Remove alert
- Alert signal event support
- Apply XML Schema validation against attachment
- Apply XML Schematron validations against attachment, and create report, assign overall result to variable
