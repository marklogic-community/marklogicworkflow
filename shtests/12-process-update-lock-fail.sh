#!/bin/sh

. ../config/webserver-settings.sh

sleep 5

echo "starting 12-process-update-lock-fail.sh"

PID=`cat 06-process-create-out.txt`

curl -v --anyauth --user workflow-user:workflow-user -X POST \
    -d@"./12-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process?rs:processid=$PID&rs:lock=true" > 12-process-update-lock-fail-out.txt

echo "12-process-update-lock-fail.sh complete" 
