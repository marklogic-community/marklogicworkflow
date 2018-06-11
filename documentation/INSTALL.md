## Installation methods

There are two main ways to install the marklogicworkflow project:

* Roxy Installation (stand-alone project, or starting point for a new project)
* Add modules to existing project

## Roxy Installation

To install via roxy, edit the properties file for the target environment - for example, ``deploy/local.properties`` and run the following commands:

    ./ml local bootstrap
    ./ml local deploy modules
    ./ml local deploy cpf

For more deployment details see the [Roxy project ](https://github.com/marklogic-community/roxy)

Note that if left as is, the [Roxy test harness](https://github.com/marklogic-community/roxy/wiki/Unit-Testing) will also be set up at http://localhost:8042/test/

## Adding to an existing project

### Configuring a database for MarkLogic Workflow

You can install a MarkLogic Workflow modules database from the src/workflowengine folder within this repository. Once done,
your application's app server can be configured to either use this modules database, or more likely, use a modules
database whose modules database points to this database (modules database chaining).

You can also optionally install the REST extensions and search options in the rest-api folder of this repository
to allow external applications to integrate to MarkLogic Workflow. Install these extensions in your app server. The
correct triggers and modules databases will be automatically determined by the MarkLogic Workflow code
with no extra work from yourself.

You need to ensure your content database has a Triggers database configured, and that CPF is enabled
(with NO global domain) before you try and deploy a process model in MarkLogic Workflow.

*Installation including triggers and REST extensions will be performed automatically via the Roxy commands above.*

### Configure MIME types

Default filenames for SCXML and BPMN2 models are .scxml and .bpmn respectively. These aren't recognised by MarkLogic
by default. Add these types are application/xml mime types in MarkLogic Server for them to be handled correctly.  *This will be performed automatically via Roxy bootstrap.*

### Configure Indexes

The project requires two range element attribute indexes:

* wf:process/@id
* wf:process/@attachment

See deploy/ml-config.xml for full details.  *These will be generated automatically via a Roxy bootstrap.*

### Configure global process task settings

Some tasks require global configuration. An example of this is the email task which requires SMTP settings.

TODO: Provide a standard way to support this.
