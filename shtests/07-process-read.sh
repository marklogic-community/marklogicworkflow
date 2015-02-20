#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 07-process-read.sh"

PID="8d352992-0f85-497a-ab97-e47c89de22f5-2015-02-11T08:37:49.708051-08:00"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X GET \
    -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process?processid=8d352992-0f85-497a-ab97-e47c89de22f5-2015-02-11T08:37:49.708051-08:00" > 07-process-read-out.txt

echo "07-process-read.sh complete"
