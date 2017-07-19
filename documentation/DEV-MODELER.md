This file contains information on the custom MarkLogic Workflow Runtime Environment for the Eclipse BPMN2 modeller.

# Eclipse BPMN2 Modeler Extension

MarkLogic Workflow provides two Target Runtimes for the Eclipse BPMN2 modeler, and associated custom tasks. The two
target runtimes are:-
- MarkLogic Workflow - High level content and human centric workflow
- MarkLogic Content Processing Framework (CPF) - Low level document state and lifecycle machine

These runtimes provide their own New File dialogues within the BPMN2 category in Eclipse. The resultant process model
types (CPF or Workflow) provide a restricted and customised palette of BPMN2 Activities tailored specifically for
the MarkLogic Workflow and CPF environments.

This ensures that model developers cannot use any features not supported by MarkLogic CPF and MarkLogic Workflow. In
addition, default Interfaces, messages, and other process configuration is automatically provided within these process
model types.

You should strongly consider using the 'MarkLogic Workflow Process Diagram' or 'MarkLogic CPF Process Diagram' types
rather than the default Generic BPMN2 Process Diagram in order to ensure your processes can execute inside MarkLogic.

## Running the modelling extension

In future this extension may be bundled inside the standard BPMN2 modeler, and so installed BPMN2 modeler will give
you access to everything you need.

Until this happens, or if you need the very latest MarkLogic Workflow model element support whilst working on a new
project, you will need to execute the extension manually.

### Latest from source (any branch) for Plugin development

*Newer versions of Eclipse may be better supported under the develop branch*

Note: If following the Contributing guide, you should have logged an issue and created a new branch from develop using
```sh
$ git checkout -b feature-ISSUEID develop
```

To execute the latest extension from source:-
- Checkout or download the zip of the latest (develop or feature branch) of MarkLogic Workflow at http://github.com/marklogic-community/marklogicworkflow
- Open Eclipse Luna (4.4) or above
- Go to File -> Import project
- Navigate to ./marklogicworkflow/eclipse/org.eclipse.bpmn2.modeler.runtime.marklogic (NOT just ./marklogicworkflow)
- Import this workspace
- Double click on the 'plugin.xml' file
- In the top right of the edit dialogue for this file, click the green Play button. This launches Eclipse Luna with this extension

### Current published In Development version

- In Eclipse Luna (4.4) or above, go to Help -> Install new software
- In the update site field type https://raw.githubusercontent.com/adamfowleruk/marklogicworkflow/develop/eclipse/MarkLogicWorkflowUpdateSite
- It will take a few seconds to download plugin information
- Select the Eclipse BPMN2 Modeler - MarkLogic Workflow Runtime Extension Feature
- Click Next
- Follow the prompts
 - NOTE: If you are warned about the project not being signed, click on 'OK' and NOT 'Cancel' to proceed with installation
- Restart Eclipse Luna

### Current published released version

- As for Current published in development version, except use this URL: https://raw.githubusercontent.com/adamfowleruk/marklogicworkflow/master/eclipse/MarkLogicWorkflowUpdateSite

## Creating a new Workflow process diagram

- Now go to File - Import or File - New Project to create your new modelling project
- Right click the root folder and select New - Other
- Open the 'BPMN2' category and select either 'MarkLogic CPF Process Diagram' or 'MarkLogic Workflow Process Diagram'
- Ensure the 'set runtim to...' tickbox is ticked (the default)
- Click next and follow the prompts in the wizard as necessary. Process model names cannot include spaces or hyphens (-)

That's it! You now have a new model. In the right hand side of the model editor you'll see a restricted set of tasks that
you can use in your model. Just drag/drop them on to the editor and connect as necessary.

When finished, save the file. Fix any red validation errors that appear after save. Then use the MarkLogic Workflow
REST API to install your model (PUT /v1/resources/processmodel)

## Exporting a CPF pipeline for editing

In the future MarkLogic Workflow will allow any arbitrary CPF pipeline to be exported and modelled in Eclipse BPMN2
modeler. This will allow for full round trip re-engineering of MarkLogic CPF processes.

*WARNING: It should be noted that CPF diagram support is very much an Alpha product and not scheduled to be fully
implemented for a while.*

## Related information

The best source for Eclipse extension tutorials is:-
https://wiki.eclipse.org/BPMN2-Modeler/DeveloperTutorials

These have been updated for the latest Luna version of the Eclipse BPMN2 modeler

You may also find it instructive to download the 'jBPM Runtime Extension' project from the above project's GitHub site.
 I use this for many examples.

A developer forum is also available: https://www.eclipse.org/forums/index.php/f/226/
