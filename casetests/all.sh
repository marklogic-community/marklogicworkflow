#!/bin/sh

echo "Testing the MarkLogic Workflow Case Management REST API..."

. ./01-create-case.sh
. ./02-update-case.sh
. ./03-get-case.sh
. ./04-close-case.sh
. ./05-get-closed-case.sh

echo "Completed all tests for MarkLogic Workflow Case Management"

exit 0
