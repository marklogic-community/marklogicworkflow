#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 32-processmodel-create-fork-simple.sh"

curl -v --anyauth --user $WFMANU:$WFMANP -X PUT \
    -d@"../data/examples/bpmn2/fork-simple.bpmn2" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processmodel?rs:name=fork-simple.bpmn2&rs:enable=true" > 32-processmodel-create-fork-simple-out.txt

echo "32-processmodel-create-fork-simple.sh complete"
