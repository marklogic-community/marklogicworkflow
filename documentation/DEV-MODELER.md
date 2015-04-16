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

To execute the latest extension:-
- Checkout or download the zip of the latest (develop branch) of MarkLogic Workflow at http://github.com/adamfowleruk/marklogicworkflow
- Open Eclipse Luna (4.4) or above
- Go to File -> Import project
- Navigate to ./marklogicworkflow/eclipse/org.eclipse.bpmn2.modeler.runtime.marklogic (NOT just ./marklogicworkflow)
- Import this workspace
- Double click on the 'plugin.xml' file
- In the top right of the edit dialogue for this file, click the green Play button. This launches Eclipse Luna with this extension
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

For the custom runtime/task videos, see this first:-

http://bobsbizbuzz.blogspot.it/2014/06/blog-post_10.html
