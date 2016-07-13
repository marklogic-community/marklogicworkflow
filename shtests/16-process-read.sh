#!/bin/sh

# pause to ensure process is complete (so we can read audit data)

sleep 10

. ../config/webserver-settings.sh

echo "starting 16-process-read.sh"

PID=`cat 06-process-create-out.txt`

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X GET \
    -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process?rs:processid=$PID" > 16-process-read-out.txt

echo "16-process-read.sh complete"
