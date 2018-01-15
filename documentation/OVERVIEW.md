
## What this project is

The project aims to provide just enough functionality to provide a 'content centric workflow' capability within MarkLogic
Server, and no more. Hence the moniker 'MarkLogic Workflow'.

Primary aims:-
- Provide a way to configure CPF pipelines on MarkLogic
- Provide a set of actions that perform high level processing logic common to modelling formats (if/then, switch/case, fork/rendezvous, add audit log)
- Provide an easy way to configure a specific process model instance to be executed when a new document enters MarkLogic
- Incorporate existing MarkLogic pipeline actions without any code changes (E.g. start the document conversion pipeline for a specified document)

Note the internal classes refer to the MarkLogic Workflow fature set as the 'process engine'. This is purely the name
for the modelling and execution part of MarkLogic Workflow.

## What this project isn't

This project does not aim to provide a full fledged end to end BPM Suite (BPMS) incorporating process modelling, simulation,
business activity monitoring, workforce management, or full round trip (six sigma style) process re-engineering.

This project also does not try and provide any user interface at all over the workflow engine.

This project is NOT a 'process engine' or 'business process management engine' or 'BPEL engine' or 'BPM Suite'.

This project specifically does not provide any actions to affect external systems, other than the possibility of
invoking a SOAP or REST service (which are anyway primarily aimed at invoking systems that enrich documents or translate
text and such).

## The future

It is possible this project may extend the workflow data model in order to add 'Case folder' and 'case management'
actions that may be of use when implementing a case management system over MarkLogic Workflow.

KT is also looking at plugging an E-forms tool in to MarkLogic Server. This brings the tantilising prospect of a way
to configure content centric workflow applications with a user interface over documents in MarkLogic Server.

This system could then be used for pre-sales demonstrations of complex information management scenarios beyond the usual
simple 'add document' and 'search for document' capabilities of MarkLogic Server.

## Information

- [Installing MarkLogic Workflow](INSTALL.md)
- [Creating a MarkLogic Workflow compatible BPMN2 model](MODELLING.md)
- [Using MarkLogic Workflow processes](USING.md)
- [Developing and extending MarkLogic Workflow](DEVELOPER.md)
