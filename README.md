A way to import and execute BPMN2 process models using MarkLogic's CPF feature.

## What is MarkLogic Workflow?

This project aims to provide a way to use the dominant BPMN2 process modelling standard in order to provide a way to
build workflows that can be executed within MarkLogic's Content Processing Framework (CPF) feature.

Many customers of MarkLogic desire simple content and human centric workflows rather than complex ESB/JMS system-to-system integration. A full-fledged separate BPM suite therefore forces them to install a great deal more infrastructure
and has a higher learning curve than is necessary to support these workflows.

MarkLogic Workflow uses the MarkLogic Enterprise NoSQL Database and it's document state processing functionality - CPF -
in order to provide a single integrated platform for MarkLogic-document and human user centric workflow modelling and
processing.

This provides customers with an easy entry point in to content-centric BPM for long-lived processes that use MarkLogic
stored content. It does this at minumum cost, with no extra working
parts (other than a modelling tool), and uses open standards and open source software to minimise vendor lock in.

Example processes that can be implemented:-

- Content review/approval workflows
- Content change request workflows
- Content creation request workflows
- Case management workflows using content about a person/event/customer/place as context for a human user's decision making
- Long term content review and disposition (policy driven deletion) workflows

## Why use MarkLogic Workflow?

Good question. A few quick reasons:-

- No additional cost for existing MarkLogic customers
- Extends CPF to allow parallel execution of sub-processes and inclusion of multiple documents, or none, in a single process
- Uses MarkLogic Alerting to precisely identify which documents affect which processes, at a more granular level that CPF Domains
- Introduces the concept of human steps, and work queues, which CPF does not support
- Implemented using CPF - which means long running processes have ZERO PROCESSING COST when not active - this is UNIQUE in the BPM space
- Uses the dominant BPMN2 standard and provides a MarkLogic view in the Eclipse BPMN2 modeler, a leading open source BPM modelling application, used by jBPM also, avoiding vendor lock-in

MarkLogic workflow does not aim to be a full fledge BPM Suite providing round trip business process re-engineering. It is
also not aimed at system to system integration, although will be able to invoke and be invoked by web services in a future
release. MarkLogic workflow can, therefore, act as part of an overall SOA architecture that also includes system to system
BPM environments like IBM WebSphere Process Server or TIBCO ActiveMatrix BPM.

## Information on MarkLogic Workflow
- Overview
 - [Product overview](./documentation/OVERVIEW.md) -- START HERE!!!
 - [Technical overview](./documentation/TECHINTRO.md)
- For workflow modellers/implementors
 - [Installation](./documentation/INSTALL.md)
 - [BPMN2 modelling](./documentation/MODELLING.md)
 - CPF pipeline modelling - TBC
- For developers
 - [Developer howtos](./documentation/DEVELOPER.md)
 - [Upcoming features list](./documentation/SPRINTS.md)
