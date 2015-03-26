#!/bin/sh

echo "Testing the MarkLogic Workflow REST API..."

. ./01-processmodel-create.sh
. ./02-processmodel-read.sh
. ./03-processmodel-update.sh
. ./04-processmodel-publish.sh

. ./06-process-create.sh
. ./07-process-read.sh

. ./08-processinbox-read.sh

. ./09-process-update.sh
. ./10-processqueue-read.sh
. ./11-process-update.sh
. ./12-process-read.sh



# . ./x05-processmodel-delete.sh

echo "Completed all tests for MarkLogic Workflow"

exit 0
