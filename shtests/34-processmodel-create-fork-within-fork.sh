#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 34-processmodel-create-fork-within-fork.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X PUT \
    -d@"../data/examples/bpmn2/fork-within-fork.bpmn2" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processmodel?rs:name=fork-within-fork.bpmn2&rs:enable=true" > 34-processmodel-create-fork-within-fork-out.txt

echo "34-processmodel-create-fork-within-fork.sh complete"
