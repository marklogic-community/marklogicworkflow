#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 23-process-create.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X PUT \
    -d@"./23-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: text/plain" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process" > 23-process-create-out.txt

echo "23-process-create.sh complete"
