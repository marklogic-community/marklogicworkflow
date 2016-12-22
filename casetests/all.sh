#!/bin/sh

echo "Testing the MarkLogic Workflow Case Management REST API..."

. ./01-create-case.sh
. ./02-get-case.sh
. ./03-update-case.sh
. ./04-get-case.sh
. ./05-close-case.sh
. ./06-get-closed-case.sh

echo "Completed all tests for MarkLogic Workflow Case Management"

exit 0
