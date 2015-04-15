#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 21-processmodel-create.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X PUT \
    -d@"../data/examples/bpmn2/022-email-test.bpmn" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processmodel?rs:name=022-email-test.bpmn&enable=true" > 21-processmodel-create-out.txt

echo "21-processmodel-create.sh complete"
