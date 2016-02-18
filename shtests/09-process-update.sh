#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 09-process-update.sh"

PID=`cat 06-process-create-out.txt`

curl -v --anyauth --user $WFUU:$WFUP -X POST \
    -d@"./09-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process?rs:processid=$PID&rs:complete=true" > 09-process-update-out.txt

echo "09-process-update.sh complete"
