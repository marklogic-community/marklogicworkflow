#!/bin/sh

. ../config/webserver-settings.sh

sleep 5

echo "starting 14-process-update-lock.sh"

PID=`cat 06-process-create-out.txt`

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X POST \
    -d@"./14-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process?rs:processid=$PID&rs:lock=true" > 14-process-update-lock-out.txt

echo "14-process-update-lock.sh complete"
