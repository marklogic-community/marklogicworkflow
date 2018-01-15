# Cheat sheet guide for the BPMN2 spec

A copy of the [BPMN2 spec](./bpmn2omg/10-06-02.pdf) PDF is also available.

## Activities supported in the spec

- Task
- Manual Task -> External (E.g. paper based) task to process engine
- Script task
- Business rule task -> Requires BRE implementation
- receive task -> Requires service endpoint implementation
- send task -> invoke web service as fire and forget
- service task -> invoke service and process response
- sub-process -> can be triggered by event rather than direct calling
- transaction -> commit or cancel transaction
- user task -> aka human step
- ad hoc sub process
- call activity

- loop characteristic available in activity definitions rather than as separate process step

- call activity (process or global task)

- gateway -> all can fork or rendezvous processes
- parallel gateway -> fork to or synchronise from all flow paths
- complex gateway -> E.g. 3 of 5 incoming routes required in order to activate gateway
- event based gateway
- exclusive gateway -> Decision point with one outcome

- error event
- escalation event
- message event
- signal event

- pluggable data store implementations

- can import XSD, WSDL, BPMN2 for types and services

- terminate current process
- timer (duration or specific date time)

- input and output sets (overloaded activities like methods)

## Model serialization

XPDL 2.2 is the XML file format of BPMN 2. This is covered in the BPMN2 specification.

## BPMN2 elements not supported by jBPM (and thus not often used in BPMN2 eclipse modeler)

- call choreography
- collaboration
- correlation property
- import -> We may support this?
- sub choreography
- call conversation
- complex gateway
- dorrelation subscription
- message flow
- sub conversation
- choreography
- conversation
- Data store -> We may support this?
- Participant -> We may support this?
- Transaction
- Choreography task
- conversation link
- global tasks
- standard loop characteristics

## Customisation of Eclipse BPMN2 modeler for MarkLogic

- Use a Tool Profile to limit BPMN2 elements available (Based on target runtime and diagram type)
- read page 60 of the BPMN2 modeler user guide PDF
