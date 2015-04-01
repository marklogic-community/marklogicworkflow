#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 11-process-update.sh"

PID=`cat 06-process-create-out.txt`

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X POST \
    -d@"./11-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process?rs:processid=$PID&rs:complete=true" > 11-process-update-out.txt

echo "11-process-update.sh complete"
