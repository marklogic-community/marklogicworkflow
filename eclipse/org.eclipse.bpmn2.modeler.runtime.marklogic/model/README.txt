drools.ecore and bpsim.ecore were originally copied from here:

https://github.com/droolsjbpm/jbpm/tree/master/jbpm-bpmn2-emfextmodel/src/main/resources/model

The following changes are required for the BPMN2 Modeler:
1. DocumentRoot subclasses the DocumentRoot in bpmn2 model, so need to remove
mixed, xMLNSPrefixMap and xSISchemaLocation
2. The name of the "import" container in DocumentRoot had to be changed to "importType" because bpmn2.DocumentRoot
already defines an "import" container.
3. Added BPSimDataType to drools DocumentRoot. This is used to enable/disable the simulation property tab
from Project Preferences->Tool Enablement
4. GlobalType needs to subclass ItemAwareElement so that it can be used in the same context as BPMN2 Property elements. 