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

## Notes on the CPF configuration of custom steps

Some things of note when creating a new step type:-

- If your step needs to wait for an external manual action (E.g. its a human task or a receive web service task) then its on-success state should be blank. (This should be set by the external process)  

## Update the BPMN2 importer code

Don't forget to update the /app/models/workflow-import.xqy code to conver the BPMN2 representation of your step to
a CPF state and link to an action. All BPMN2 custom configuration should be copied in to the CPF action's options XML element.

## Deploy your modules

./mljsadmin --install=modules

You should now be able to import a new BPMN2 model with your custom action type and execute the model successfully.
