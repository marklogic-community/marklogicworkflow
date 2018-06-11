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

## Gateways

Gateways are supported as below. The fork and rendezvous semantics are as follows:-

| Gateway | Fork method | Rendezvous Method |
| Exclusive | CONDITIONAL (First true, or default route) | NONE (Only ever one route) |
| Parallel | NONE (All routes) | ALL |
| Inclusive | CONDITIONAL (All true, or default route) | ALL |

### Exclusive Gateway

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
- You may specify a default route to be executed always, if no other route evaluates to true

See *XQuery Expressions* later in this document for details on expressions, and examples.

### Parallel Gateway

Allows multiple simultaneous routes to be processed at the same time.

Internally, creates workflow sub-process documents and requires multiple CPF pipeline configurations - created by the importer.

First, create a parallel gateway:-
- Drop a Parallel Gateway on to the process diagram
- Click on Properties -> Gateway
- Set Gateway direction to 'Diverging'

Then create your routes:-
- Mouse over your gateway
- Click and drag the connector icon (arrow) to another step. Name this connector (route).
- Give each route a meaningful name

Finally, Synchronise all parallel flows back to another Parallel Gateway (Rendezvous):-
- Drop an Parallel Gateway on to the process diagram
- Click on Properties -> Gateway
- Set gateway direction to 'Converging'
- Connect all route flows to this second parallel gateway

### Inclusive Gateway

Like a Parallel Gateway as it allows execution of multiple routes simultaneously, but it checks the conditions on those
routes and allows a default route to be specified, just like an Exclusive Gateway.

First, create an Inclusive Gateway:-
- Drop an Inclusive Gateway on to the process diagram
- Click on Properties -> Gateway
- Set Gateway Direction to 'Diverging'

Then, create your routes:-
- Mouse over your gateway
- Click and drag the connector icon (arrow) to another step. Name this connector (route).
- Give each route a meaningful name

Then, configure your route criteria
- Click on the inclusive gateway
- Click on Properties -> Gateway
- For each route, enter an XQuery expression that evaluates to true (equals fn:true())
- You may specify a default route to be executed always, if no other route evaluates to true

See *XQuery Expressions* later in this document for details on expressions, and examples.

Finally, Synchronise all parallel flows back to another Inclusive Gateway (Rendezvous):-
- Drop an Inclusive Gateway on to the process diagram
- Click on Properties -> Gateway
- Set gateway direction to 'Converging'
- Connect all route flows to this second inclusive gateway

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


*WARNING: If you type 'RejectedEmail' as the name of the Out Message, then MarkLogic workflow will check the MODULES
database for a document called /workflowengine/assets/PROCESSNAME/MAJORVERSION/MINORVERSION/RejectedEmail.xml. If this
document does not exist, it will check in the major version folder, and failing that in the process name folder. This is
because (unbelievably) BPMN2 does not support data modelling, and such the structure of the message is out of scope of
the modelling tool. It is possible to add a 'structure' definition in BPMN2 that points to a fixed XML message, BUT this
is not supported by any modelling tool! Only XML Schema (for the structure of the email, not the template) is supported.*

The format of the outgoing email message (Out Message) can be found in the
[xdmp:email online docs](http://docs.marklogic.com/xdmp:email).

Now go back and edit the Send Task:-
- Left click on the send task
- Click on Propeties
- Click on the 'Send Task' tab
- In attributes:-
 - Set implementation to Unknown
 - Set Operation to EmailInterface/SendRejected (or whatever you called it)
 - Message should be automatically selected (RejectedEmail in my example 021-initiating-attachment.bpmn)

Save the process diagram (validates your configuration of the task - no red stars mean it's configured properly).

For configuring a local mail agent to test this task, see [The CentOS website](http://wiki.centos.org/HowTos/postfix#head-c02f30bf0669d9b47a6c14c114243338b5ea1f27). Don't forget to set an
alias pointing 'admin' at your local linux machine's logged in user - you can then use Thunderbird to receive email
from the sample processes.

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
