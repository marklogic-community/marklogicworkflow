#!/bin/sh

echo "Testing the MarkLogic Workflow REST API..."

. ./01-processmodel-create.sh
. ./02-processmodel-read.sh
. ./03-processmodel-update.sh
. ./04-processmodel-publish.sh

. ./06-process-create.sh
. ./07-process-read.sh

. ./08-processinbox-read.sh

sleep 15

. ./09-process-update.sh
. ./10-processqueue-read.sh

sleep 15

. ./11-process-update.sh
. ./12-process-read.sh


sleep 5

. ./21-processmodel-create.sh
. ./22-processmodel-publish.sh
. ./23-process-create.sh
. ./24-process-read.sh
. ./25-processsubscription-create.sh
. ./26-processsubscription-read.sh
. ./27-document-create.sh
# Search needs to be immediately after - it executes too quick otherwise!!! (A blank result may mean processes already finished, not just haven't started)
. ./28-processsearch-read.sh


# . ./x05-processmodel-delete.sh

echo "Completed all tests for MarkLogic Workflow"

exit 0
