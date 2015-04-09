The step documentation. Note all instructions assume you are using the Eclipse BPMN2 Modeler application.

Very much a work in progress.

## Start Event

The start event is used to create a first step in a CPF Workflow. No additional parameters are currently supported.
In future it is intended that alerts and subscriptions will be configureable with start or other event types.

See the CPF action startEvent.xqy for the implementation.

## End Event

The end event is used to signify the end of a process. Executes the CPF end state and finishes the process lifecycle.

See the CPF action endEvent.xqy for the implementation.

## Route

Named routes are supported for transitioning between process steps. They are used to determine which step to execute
next in CPF. No parameters or other configuration is supported.

There is no corresponding CPF action for a Route.

## Task

The generic task step is used to generate a generic CPF state that immediately completes. This is useful as a
placeholder for a future user task that you're not ready to implement yet. No parameters are interpreted.

See the CPF action task.xqy for the implementation.

## User Task

Allows assigning a human task to an individual user (MarkLogic user id), Role (MarkLogic role name) or
Queue (arbitrarily named shared queue).

See the CPF action userTask.xqy for the implementation.

First, to create a User Task:-

- Drop on a User Task (NOT a Task) on to the diagram
- Click on Properties -> User Task

Then ...

a) To configure a User Task assigned to a named MarkLogic user:-
- Add a resource with name 'Assignee' and value matching the MarkLogic User Name (string, not integer ID) of the user to be assigned the task

b) To configure a User Task assigned to a MarkLogic role:-
- Add a resource with name 'Role' and value matching the MarkLogic Role Name (string, not integer ID) of the role to be assigned the task

c) To configure a User Task assigned to anyone with access to a named work queue:-
- Add a resource with name 'Queue' and value matching the Queue Name (any arbitrary string) of the queue the task should be added to

Note: Although it is called a Queue, work can be completed in any order.

## Exclusive Gateway

The ability to select a single execution route based on a list of choices and evaluated criteria. A decision point.

See the CPF action exclusiveGateway.xqy for the implementation.

First, create an Exclusive Gateway:-
- Drop an Exclusive Gateway on to the process diagram
- Click on Properties -> Gateway
- Set Gateway Direction to 'Diverging'

Then, create your routes:-
- Mouse over your gateway
- Click and drag the connector icon (arrow) to another step. Name this connector (route).
- Give each route a meaningful name

Finally, configure your route criteria
- Click on the exclusive gateway
- Click on Properties -> Gateway
- For each route, enter an XQuery expression that evaluates to true (equals fn:true())

See *XQuery Expressions* later in this document for details on expressions, and examples.

## Send Task

This task can send SOAP, HTTP-REST and Email messages (amongst others). It is currently in development, with smtp
email sending support scheduled first, and other features being added as needed later.

See the CPF action sendTask.xqy for the implementation.

First, create a Send Task:-
- Drop a Send Task on to the process diagram
- Click on Propeties -> Send task

Note that you have to assign an operation and a message. These are actually created at the top level of the process diagram.

To create an operation:-
- Left click on the background of the process diagram
- In the bottom window, click Properties
- Click on the Interfaces tab
- Under 'Interface List', click the plus icon
- Create an interface with the EXACT name EmailInterface with Implementation set to EXACTLY EmailInterface
- Add an operation for each individual email template you wish to send (E.g. send rejected, send accepted)
- You can name these anything you like, be sure to provide a name and an implementation name
- Set the Out Message to point to an XML Schema definition that consists of your message

TODO Document how the VALUE not SCHEMA for this message is created (read BPMN2 spec and examples).

Now go back and edit the Send Task:-
- Left click on the send task
- Click on Propeties
- Click on the 'Send Task' tab
- In attributes:-
 - Set implementation to Unknown
 - Set Operation to EmailInterface/SendRejected (or whatever you called it)
 - Message should be automatically selected (RejectedEmail in my example 021-initiating-attachment.bpmn)

Save the process diagram (validates your configuration of the task - no red stars mean it's configured properly).

## Additional notes

There are some configuration elements that are true across multiple steps. These are documented below.

### XQuery Expressions

**Example boolean expression:-**
/wf:process/wf:data/choiceB = 'A'

**Another example boolean expression:-**
$wf:process/wf:data/choiceB = 'A'

**Third equivalent boolean expression:-**
$processData/choiceB = 'A'

As you can see from the above a forward slash is interpreted as the current document (NOT all documents from fn:doc()),
and $wf:process means the root of the process document. $processData is a shortcut for the data segment. If in doubt,
use $processData in order to avoid placing data in the wrong location of the process document. (An envelope pattern is
  in use - you shouldn't try and change data elsewhere in this process document yourself - that is for MarkLogic
  Workflow to do).
