This file describes how to start a new MarkLogic Workflow process instance automatically when a new document is created,
or updated.

## Process Subscription design aims

I had a design decision to make - do I use the document whose creation (or update) kicks off the CPF pipeline as the main
'context' for a workflow process, or a separate document? Does this document contain copies of the full document content,
or a subset, or none at all. My design incorporates both a content mapping set of functionality, and references to other
documents, called attachments.

The 'process document' has a wf:data element (containing any other XML data for the process), and a wf:attachments element (basically named URI pointers). A set of mapping functionality will allow you to selectively copy data to/from this process document and an attachment. Some data in wf:data may be internal to the process only, rather than from another source document. E.g. a human chooses their action to be 'approved' or 'rejected'.

For example, on initial submission of an eform a subset of the total data present may be required for process decision making and routing. The process designer shouldn't care that the eform schema itself changes so long as these properties are present. Likewise the document creator shouldn't need to know how the process is going to update data in the eform after submission. Makes a nice separation of concerns.

The attachment idea is a powerful one. You can allow (or require) a person working on a task to specify an attachment. This is what we did in my FileNet days. Perhaps more interestingly for us is the possibility of the attachment being a saved search that defines a 'working set' of data for an ad-hoc 'community of interest'. It could even be a simple 'folder' name, such as a case folder.

On the evaluation side, BPMN2 supports by default XQuery (Yey!) conditions, so it's actually pretty trivial to support fetching an element from an attachment and testing its content using the full range of XQuery available to you. E.g. (fn:doc($wf:process/wf:attachments/wf:attachment[./@name='InitiatingAttachment']/uri/text())/some/other/property = 'avaluehere') - You could use this to determine which route in a workflow to take. ($wf:process being a wildcard I replace in a library call when evaluating conditions).

The above is why I decided to have a process document that CPF runs against, rather than running CPF against a 'source' document. So I'll have a separate Alert configured to check for 'Eform Applications' which has an alert action to create a process document and map over any data required, linking the eform as an 'initiating attachment'. The creation of this process document then falls in to the CPF domain, starting the relevant (and versioned) pipeline.

## How it works

1. A user, or application, creates a new document in MarkLogic - say a Bank Account Opening E-form
2. A 'Process Subscription' (basically a MarkLogic alert that uses the alert-action-process.xqy action) fires, creating a new Account Opening process document
3. A CPF Domain (set up by enabling/publishing a MarkLogic Workflow BPMN2 model) fires for this document, invoking the Account Opening V1.2 CPF pipeline process
4. CPF manages the state transitions and execution of BPMN2 CPF actions throughout the process lifecycle
5. Process eventually completes (or fails), leaving the process document as an audit record of what happened, with metrics for performance analysis

## Why use an alert instead of a CPF domain?

Several reasons.

- A given process may have many individual documents associated with it (account opening form, risk analysis, id documentation, credit score result)
- Only 1 CPF pipeline can work on a single document at a time, making parallel processes impossible to implement
- A need for an audit trail outside of a document
- The ability to have different security on the process than the source document
- Not wanting to pollute the source document with process state information

## Isn't it a bit convoluted?

If you had to create all these things by hand, yes. This is why the Workflow REST API provides a single endpoint
(POST /v1/resource/process) to take a BPMN2 model, create a set of CPF pipelines, and create a
domain configuration, for you.

All you then need to do then is separately configure one or more Alerts (aka Process Subscriptions) via calls to
PUT /v1/resource/processsubscription to start the relevant workflow based on criteria about a new or updated document
in marklogic.

Alternatively, manually start a process via PUT /v1/resource/process without needing a Process Subscription. This is useful
if starting a process via an ESB or application. A good example is starting a process to tell a person to create a
new document that doesn't exist yet.
