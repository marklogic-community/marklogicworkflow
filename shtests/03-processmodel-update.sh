#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 03-processmodel-update.sh"

curl -v --anyauth --user $WFDESU:$WFDESP -X PUT \
    -d@"../data/examples/bpmn2/015-restapi-tests.bpmn" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processmodel?rs:name=015-restapi-tests.bpmn&rs:major=1&rs:minor=2" > 03-processmodel-update-out.txt

echo "03-processmodel-update.sh complete"
