## Installation methods

There are two main ways to install the marklogicworkflow project:

* [Gradle](https://gradle.org/) Installation (stand-alone project, or starting point for a new project)
* Add modules to existing project

## Gradle Installation

To install via gradle, create a properties file for the target environment - for example, ``gradle-local.properties`` - default values will be picked up from gradle.properties

    mlHost=localhost
    mlUsername=admin
    mlPassword=admin

To deploy, run the following command:

    gradle mlDeploy

An example properties file is supplied for deploying MarkLogic Workflow with Case Management (gradle-case.properties) - to use:

    gradle mlDeploy -PenvironmentName=case

For more deployment details see the [ml-gradle](https://github.com/marklogic-community/ml-gradle)

Note that if left as is, the [ML Unit test harness](https://marklogic-community.github.io/marklogic-unit-test/) will also be set up at http://localhost:8042/test/

## Adding to an existing project

### Configuring a database for MarkLogic Workflow

You can install a MarkLogic Workflow modules database from the src/main/ml-modules/root/workflowengine folder within this repository. Once done,
your application's app server can be configured to either use this modules database, or more likely, use a modules
database whose modules database points to this database (modules database chaining).

You can also optionally install the REST extensions and search options in the src/main/ml-modules/services folder of this repository
to allow external applications to integrate to MarkLogic Workflow. Install these extensions in your app server. The
correct triggers and modules databases will be automatically determined by the MarkLogic Workflow code
with no extra work from yourself.

You need to ensure your content database has a Triggers database configured, and that CPF is enabled
(with NO global domain) before you try and deploy a process model in MarkLogic Workflow.

*Installation including triggers and REST extensions will be performed automatically via the gradle command above.*

### Configure MIME types

Default filenames for SCXML and BPMN2 models are .scxml and .bpmn respectively. These aren't recognised by MarkLogic
by default. Add these types are application/xml mime types in MarkLogic Server for them to be handled correctly.  *This will be performed automatically via the gradle command above.*

### Configure Indexes

The project requires two range element attribute indexes:

* wf:process/@id
* wf:process/@attachment

See /src/main/ml-config/databases/content-database.json for full details.  *These will be generated automatically via the gradle command above.*

### Configure global process task settings

Some tasks require global configuration. An example of this is the email task which requires SMTP settings.

TODO: Provide a standard way to support this.
