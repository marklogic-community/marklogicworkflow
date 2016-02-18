#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 33-processmodel-create-fork-conditional.sh"

curl -v --anyauth --user $WFMANU:$WFMANP -X PUT \
    -d@"../data/examples/bpmn2/fork-conditional.bpmn2" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processmodel?rs:name=fork-conditional.bpmn2&rs:enable=true" > 33-processmodel-create-fork-conditional-out.txt

echo "33-processmodel-create-fork-conditional.sh complete"
