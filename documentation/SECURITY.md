## Security

MarkLogic Workflow contains several security features that help mitigate any potential attack vectors.

Process modelling by necessity includes configuring conditions on routes and sometimes invoking custom application
scripts. These conditions and scripts operate on the data that is part of the process. This can include free text fields
copied from the context document(s) in to the process document, or evaluated via fn:doc.

It is theoretically possible therefore for MarkLogic Workflow to evaluate text through erroneously coded scripts and
conditions. This provides a vector for XQuery injection attacks. The source of these could be organisational (a naughty
workflow designer) or external (someone submitting an eform which is later automatically evaluated).

In either case, appropriate security constraints and auditing needs to be provided. This document summarises what
security features have been implemented for MarkLogic Workflow in addition to those already provided in MarkLogic
Server.

It is assumed that the reader is already familiar with MarkLogic Security. If not, please go and read the security
guide here: http://docs.marklogic.com/guide/security

When setting up a development, test, or production system please follow the privileges laid out in this document.

NOTE: When configuration a production system you probably don't want the USERS mentioned below - they are just intended
for testing security of MarkLogic Workflow in development.

### Summary of security steps

All MarkLogic Workflow code is protected by a set of XQuery execute privileges. These minimise what each person with
access to the MarkLogic system can do with respect to function calls or REST API calls.

#### Code Execute privileges

Privilege name | URI | Description
---- | ---- | ----
Workflow Designer | http://marklogic.com/workflow/privileges/designer | Someone who uploads and downloads process models
Workflow Manager | http://marklogic.com/workflow/privileges/manager | Someone who publishes (activates) process models, making them executable
Workflow Administrator | http://marklogic.com/workflow/privileges/administrator | Someone who can monitor and remove live process INSTANCES
Workflow Monitor | http://marklogic.com/workflow/privileges/monitor | Someone who can only see process running status, not live process data
Workflow User | http://marklogic.com/workflow/privileges/user | Someone who can list their assigned workflows, lock them, and complete (update) them. Does not give access to EVERY workflow
Workflow Instantiator | http://marklogic.com/workflow/privileges/instantiator | Someone who can start a new workflow

#### Document creation URI Privileges

Document base URI | Privilege required
---- | ----
/workflow/processes/ | workflow-instantiator-uri
/workflow/models/ | workflow-designer-uri

### Privilege rationale

The designer should be allowed to upload new versions of processes, and download processes. Access to the functions
allowing this are via the designer privilege. Access to the individual BPMN2 models are via document permissions as
normal.

The manager can publish a workflow, with generates CPF pipelines and domains in the LIVE triggers database. This
effectively allows the process to be executed. They are also allowed to remove a process from being executed in live.
They are not allowed to upload their own models (only the designer is) or start/stop their own processes (which an
administrator, or the role(s) specified in the BPMN2 startEvent are allowed to do). Thus they cannot introduce a live
process themselves and remove all trace of it without the help of both a designer and administrator. The same is true
of designers and administrators too. This minimises the chance of a single person deciding to maliciously attack
the security of the system.

The workflow user privilege exists so that it is possible to not have all users with access to store and retrieve
content in MarkLogic Server to also be able to work on workflows. (This can be done though, but requires a positive
action by a MarkLogic Server administrator.)

The monitor privilege exists so users can monitor the status and health of the MarkLogic Workflow system, but not the
transient data held within running workflows. This also means that an administrator terminating a process can be
spotted by a workflow monitor user, again providing audit security in depth.

The workflow instantiator privileges (one execute and one uri privilege) prevent any user from instantiating a workflow
by manually creating a malicious process document underneath the /workflow/processes/ URI in the content database.

Things deliberately missing from the above:-

- Specific roles creating instances of specific workflows - it is envisaged that a MarkLogic Server system administrator
would create URI privileges more granular than those in workflow-instantiator-uri to control each specific workflow and
workflow version. Doing this automatically may lead to a lot of privileges, so this is left to the production system
administrator

### Default roles and users

On a default installation a role is created for each privilege, and a user created for each role. These follow the
pattern workflow-designer and workflow-designer-user, respectively. This is true of all the above privileges.

It is envisaged in production that the role would be created, but the users would not.

#### Workflow Designer role

- Has the workflow-designer execute privilege
- Has the workflow-designer-uri document creation uri privilege
- inherits the rest-reader and rest-writer roles
- produces documents with permissions: workflow-designer=read+write, workflow-manager=read
- produces documents with default collections: NOT SET (filled in by workflow api code)

#### Workflow manager role

- Has the workflow-manager execute privilege
- Inherits te rest-reader and rest-writer roles
- produces document with permissions: NOT SET
- produces documents with default collections: NOT SET

#### Workflow administrator role

- Has the workflow-administrator execute privilege
- Inherits te rest-reader and rest-writer roles
- produces document with permissions: NOT SET
- produces documents with default collections: NOT SET

#### Workflow monitor role

- Has the workflow-monitor execute privilege
- Inherits te rest-reader and rest-writer roles
- produces document with permissions: NOT SET
- produces documents with default collections: NOT SET

#### Workflow user role

- Has the workflow-user execute privilege
- Inherits te rest-reader and rest-writer roles
- produces document with permissions: NOT SET
- produces documents with default collections: NOT SET

#### Workflow instantiator role

- Has the workflow-instantiator execute privilege
- Has the workflow-instantiator-uri document creation uri privilege
- Inherits te rest-reader and rest-writer roles
- produces document with permissions: NOT SET
- produces documents with default collections: NOT SET

#### Workflow internal Role

WARNING: DO NOT ASSIGN THIS ROLE TO ANY USER - It is used by amps in the MarkLogic security database ONLY. Assigning
this role to a user could breach your organisation's security!

- Has the xdmp:invoke, xdmp:invoke-in, create-pipeline, create-domain privileges
- Has no URI privileges
- Has no roles inherited
- No settings for permissions or collections on created documents (assigned by workflow API explicitly only)

### Protected collection URIs

Collections are protected by providing roles rather than privileges. This is why this section is lower down in the
security document. This does not imply this setting is any less important though.

The process definition documents are held within the CONTENT database prior to being made live. In order to ensure
no ordinary user can create a workflow that a workflow-manager can then publish (activate), the collections
used should be protected as follows:-

Collection URI | Permissions
---- | ----
http://marklogic.com/workflow/model | workflow-designer=insert, workflow-designer=read, workflow-designer=update
http://marklogic.com/workflow/processes | workflow-administrator=read (WARNING: do not give workflow-instantiator=insert access, as this allows them to add arbitrary data NOT create a document in this collection)

### Additional testing notes

It is assumed that development and test systems for those working on the MarkLogic Workflow code have a user named
the same as the above roles, with ONLY that role assigned to it.

In addition to this you should create a user called workflow-non-user that is just an ordinary user of MarkLogic. This
is used to test the fact that anyone can create a document for a process subscription to fire against, without
that user having to have the workflow-user role explicitly.

It is assumed that all the above users have their password set to the same string as their username.




## Internal privileges

Note: It may be required to have a workflow-designer-internal user with the http://marklogic.com/xdmp/privileges/xdmp-invoke
privilege in order to be able to use invoke-function, and thus set up workflows.

Currently the security DB is giving an error about needing the eval permission. This is because they've not all been
replaced by invok-function yet (see top of workflow-import.xqy)

xdmp:invoke and invoke-in on eval-* functions that use xdmp:invoke, assign role workflow-internal which holds these
two privileges.

## Amps required

The below are in the http://marklogic.com/workflow-import  namespace and the /app/models/workflow-import.xqy document-uri, and the workflow-modules DB:-

local-name | roles assigned | explanation
---- | ---- | ----
eval-pipeline-get-by-name | pipeline-management | Allows reading of the CPF pipeline configuration that is held in the CONTENT database. DOESNT WORK
enable | workflow-internal | Allows call to invoke
eval-query-cpf | workflow-internal, pipeline-management | Allows call to invoke-in, and get CPF pipeline (DOESN'T WORK)
convert-to-cpf | workflow-manager | Allows install of process in modules DB before deploying to triggers db
eval-domain-create | domain-management, pipeline-management | Allows domain creation and retrieval of pipeline information for creating the domain
install-and-convert | workflow-internal | Allows conversion to CPF in modules DB
eval-pipeline-create | pipeline-management | Allows pipelines to be created in live CPF
eval-domain-delete | domain-management,pipeline-management | Allows domains to be seen and deleted in live CPF

Amps for workflow-actions.xqy:-

local-name | roles assigned | explanation
---- | ---- | ----
complete-generic (private function) | workflow-internal | Allows call to workflow-runtime:finallyComplete
update-generic | workflow-internal | Allows a normal workflow-user to update data and attachments in a live process

Amps for workflow-instantiator.xqy:-

local-name | roles assigned | explanation
---- | ---- | ----
create | workflow-internal | allows initial actions and libraries to run as workflow internal role - workflow-internal has xdmp:login privilege (and thus NO USER SHOULD EVER BE ASSIGNED THIS ROLE)

Amps for workflow-runtime.xqy:-

local-name | roles assigned | explanation
---- | ---- | ----
finallyComplete | workflow-internal | Allows CPF processing to continue as if the workflow-internal user started it.

workflow internal (aka runtime) role has the below privileges:-
- xdmp:invoke
- xdmp:invoke-in
- create-pipeline
- create-domain
- workflow-internal (obviously)
- xdmp:login (to perform a later processing action as a specific workflow-user) - locked down to a PRIVATE function.
- workflow-instantiator-uri (URI privilege)

workflow-internal role also inherits from the below roles:-
- pipeline-execution

## Security TODOs

- Determine why REST extension cannot be executed
- Check permissions on REST API code by default, then check our execute permissions on the REST extension, and import module

## Diagnosing issues

If you get a SEC-PRIV response in a rest extension this means you do not have your amps set properly.

If the extension does not exist you EITHER do not have execute privileges on the resource extension OR have
execute permissions on all required libraries - it is NOT an amp issue.
