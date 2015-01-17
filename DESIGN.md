
The MarkLogic Workflow engine consists of several distinct pieces in order to work:-

- The import tool to convert a BPMN2 or SCXML process model in to a MarkLogic CPF process model
 - MarkLogic Content Processing Framework (CPF) is the base engine for MarkLogic Workflow
- Additional CPF tasks to represent these modelling language's components
 - CPF designed originally to work on individual documents, not perform actions based on that content
- Using a document to represent running process state
 - CPF does not have a concept of a running process data model - the context document is that model
 - This also implies we need a way other than CPF domains with which to instantiate a process when a real content document is created/updated
- Creation of a 'Domain' to watch for new process documents and move them through their CPF states
 - Creating a process document is what starts a new process
 - Domains are very basic - directory or collection bound - so are not flexible enough to link processes to real content documents alone - alerts are needed
- Allowing process documents to be created manually or via an action on another real content document
 - Some processes may start and generate content to be sent out. E.g. monthly reports collating information
 - Many processes will be instantiated because a new piece of information has arrived, or has been changed (content centric processing)
- A MarkLogic Alerting API Action to take a real content document and instantiate a new process document
 - Alerting API is the most flexible way to 'subscribe' a process to a content change event (thus instantiation a new process instance)
 - Nicely decouples many different document collections and directory scopes from which process is instantiated
 - Alerting API uses Search API to be very specific as to which documents start which processes
  - Only process documents with specific content, as opposed to which collection or directory they reside in


## The process engine

A Workflow is a model of a set of actions to perform. A process is a running instance of a workflow model (aka process model).

A process engine is nothing more than a state engine with a set of logic built in. Something is needed to start a process.
Data may be mapped to this processes internal variables to enable it to make decisions.

Asynchronous processing by each step
allows human and system steps to be safely combined without having to worry about concurrent update exceptions. These
would be a barrier in a synchronous process system.

Problems of managing state and transitions, ascynrhonousness, and a task engine are already solved by CPF.

### Extending CPF

CPF provides a very good basis, but has a few shortcomings

- No data model - the document is the data model.
 - If one process can handle multiple document types, and we don't want to enforce a 'process schema' across multiple schema free documents
 - Solution: A separate process document is needed
- Only true and false conditions
 - A single step (gateway) in BPMN with 4 routes leading out of it
 - Solution: The process importer needs to create 4 CPF steps with true/false checks
- Only success and failure routes from one state to another
 - Solution: Many internal logic CPF states may be needed to represent a single BPMN 2 step
- Hard to comprehend for most mortals
 - Set theory is the domain of Computer Scientists
 - Most humans can understand a BPMN model, but not a finite state automata
 - Non existent configuration REST API
 - Multiple transactions required to configure a single CPF pipeline
 - No one really understands limited value of existing CPF pipelines, whereas workflow models and processes are well understood in Enterprises
 - Solution: Providing support for the most common process modelling standards and tools, and a high level REST API, makes MarkLogic Workflow easier than CPF on its own
- CPF is single document orientated
 - Most human decisions taken across multiple content documents
 - Separate data model required to handle internal process data and multiple 'external' content documents
 - A 'Case (folder)' implemented on top of MarkLogic workflow will need multiple documents 'filed' within it
 - Process decisions may require information from across document boundaries
 - Not supporting joins or wanting to force XInclude on people means multiple 'attachments' required
 - Solution: Abstract original document from CPF pipeline using an alert that creates a process state document, thus invoking CPF via a domain on the process state document

## A day in the life of a process

1. Administrator installs a process model, converting it to a CPF state pipeline, and creating a Domain under the processes specific folder
1. Account opening Eform arrives in MarkLogic
1. A 'process subscription' consisting of a configured Alert and the 'action process' alert action is fired
1. This action maps content from the source document to the process instance data model, and adds a reference to the content document as an attachment
1. Process document filed in a folder for this specific process (configured in the action options)
1. Multiple process documents could be created for the same document event by having multiple subscriptions (alerts) configured
1. A CPF Domain picks up the new process document and works through the pipeline representing the original process
1. Process document used as the data model for all cpf process actions
1. Custom CPF actions use this model, and update the process document with workflow audit events, and change data items
1. process document's properties fragment used to track CPF progress
1. process document remains after process completes as an audit trail for the finished process

## Cool features worth mentioning

- Using BPMN2 as a process modelling format opens up MarkLogic to a wide range of BPM skilled individuals
- Multiple process instances can be created by using multiple subscriptions (multiple installed alerts)
- Having multiple CPF processes isn't an issue as each operates on its own process document event though the source document attachment caused them all to be started (indirectly)
- A CPF pipeline action could be used to set the CPF properties on an Attachment to the process (thus forking it's cpf pipeline and starting that off)
- Processes can be started via a REST API rather than purely via creating/updating a new content document - useful for a process that creates new content
- A single folder per named process, but a CPF pipeline per named process VERSION, allows V2 processes to stay running whilst new content starts V3 processes (Single CPF domain per process folder)
- Using alerting to start a content driven process allows much more flexibility than CPF alone
