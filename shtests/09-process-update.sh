#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 09-process-update.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X POST \
    -d@"../data/examples/bpmn2/015-restapi-tests.bpmn" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process?rs:processid=$PID" > 09-process-update-out.txt

echo "09-process-update.sh complete"
