Implementing a custom step processor

## A what?

A Step Processor is a user interface that allows a human to interact with, save, view and complete a human workflow step.

Examples could include:-

- Simple HTML form allowing information to be entered, with a complete button on the page
- E-form with fields mapped to process fields, or process attachments (and multiple of these)
- Third party GUI or external case management tool with handoff/reachback in to this step

## How?

Simply use the Workflow REST API. You must perform the following in order:-

- GET the process data instance AND its properties using it's URI. Do not allow it to be opened if it has a wf:locked-by property
- POST to the process instance referring to it's URI in order to 'lock' this process for your step processor's user
- (optional) POST to the process instance, updating some data, (also optionally releasing the lock), but NOT completing the step - i.e. the user will come back later
- POST to update process data, attachments, and complete the step (thus releasing the lock)

All pretty straight forward.

I recommend that you store any settings for providing your step processor for a particular process' step external to
the process model. This keeps your UI separate from your workflow model. E.g. an Eform step processor for a 'file report'
step in a 'incident reporting' process may look for a file in the database that specified which Eform instance and version
to use for this particular step.

WARNING: When reading a process step be aware of it's exact process name including major and minor version numbers.
Your step processor may be used to open processes that are long lived, so its configuration also needs to be aware of
changing process model versions. E.g. if two process fields are added, the form version in use must also have those fields mapped.
This also allows historical forms to be opened with the correct form definition version.
