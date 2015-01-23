This document covers the very internal, deep down and dirty, in the weeds design decisions.

## Basic under bonnet design

Basic requirements, but that are still too detailed to cover elsewhere.

### Process step property extensions

CPF provides the following properties:-
- cpf:processing-status - done
- cpf:property-hash - d41d8cd98f00b204e9800998ecf8427e
- cpf:last-updated - 2010-12-07T15:01:44.177-08:00
- cpf:state - http://marklogic.com/states/done
- prop:last-modified - 2010-12-07T15:01:44-08:00

Workflow provides these additional properties:-
- wf:step-type - The Class of the workflow task. 1 or more elements. E.g. a BPMN2 User Task is also a Human Task and a Task. Used by step processors to find their steps.
- wf:step-processor - If specified in the process model, the desired step processor. Has a name attribute, and child options xml (element name as key)
- wf:locked-by - The user this step is locked by. Steps can only be opened by one user at a time. Admins in future will be able to break locks.
- wf:actions - A list of actions. The user can select only one action. Equivalent to a BPMN task followed by an exclusive gateway, or with boundary events. value attribute is what is sent to workflow, name is human readable, element text is human readable descirption
- wf:assigned-to - A name attribute for the value, a type attribute for user, group, or stack
- wf:since - Time the workflow has been at this step. Not necessarily same as last modified date
- wf:awaiting-rendezvous - Multiple elements with value being the URI of the rendezvous step
- wf:action - The chosen action by the user or workflow cpf action module
- wf:status - Either RUNNING or FAILED or COMPLETED - high level whole process status

## Basic features

These are the minimum useful features that can be implemented in a Workflow system based on CPF in order for it to be
useful.

### Implementing conditional logic in a single step

From CPF guide:-

"If you want the move the state to one that is different from the state transition's on-success state, you can use the
$override-state parameter to the cpf:success function in your default action XQuery module. You should move the state
to a different state from the document's current state. An example of a module that does this is the
/MarkLogic/cpf/actions/state-setting-action.xqy under the Modules directory."

So we can easily implement an IF and SWITCH-CASE action, leaving the success state blank on the transition.

## Advanced features

These features may be implemented once the basics are done.

### Implementing forking and synchronising

A fork necessitates multiple CPF pipelines executing. This is not a good idea on the same process document. Thus a fork
action should create multiple sub process documents, referencing their parent processes (for their data model). This
also means the first piece of code in any action should fetch the data model of the process, whether executed within
a fork, sub process, or top level process.

The fork cpf action will create a tagging element wf:awaiting-rendezvous->RV-URI element in the properties of the process
document. It will then create multiple subprocess documents. Each sub process is defined as a separate pipeline
underneath the root process URI.

A completed-fork cpf action will be needed to mark this sub process as complete. Following this every fork should
implement a check-rendezvous action to see if all (or requisite x of y) routes are complete, and if so, remove the
wf:awaiting-rendezvous->RV-URI element.

Updating this property will force the fork conditional actions to be executed. The only one of these should be one
that checks that this element has been removed, and thus transitions to the rendezvous state.

Be aware of forks within forked routes.

This should also facilitate selective rendezvous gateways where 2 of 3 routes are required in order to proceed.

### Implementing events

Events can be raised at any time, and event handlers should execute in parallel. Thus every event-receiving step
should be treated as a sub process. An event raised CPF action should create the necessary number of sub processes as
required.

Each sub process is defined as a separate pipeline underneath the root process URI. (This also allows an event in
one pipeline to execute a (sub) process defined in another).

## CPF modelling and implementation

A CPF Process model will also be directly importable from BPMN2. See the [OOTB CPF features](cpf-ootb.md) available.
