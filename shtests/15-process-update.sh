#!/bin/sh

. ../config/webserver-settings.sh

sleep 5

echo "starting 15-process-update.sh"

PID=`cat 06-process-create-out.txt`

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X POST \
    -d@"./15-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process?rs:processid=$PID&rs:complete=true" > 15-process-update-out.txt

echo "15-process-update.sh complete"
