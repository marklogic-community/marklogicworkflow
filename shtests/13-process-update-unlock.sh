#!/bin/sh

. ../config/webserver-settings.sh

sleep 5

echo "starting 13-process-update-unlock.sh"

PID=`cat 06-process-create-out.txt`

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X POST \
    -d@"./13-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process?rs:processid=$PID&rs:unlock=true" > 13-process-update-unlock-out.txt

echo "13-process-update-unlock.sh complete"
