#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 06-process-create.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X PUT \
    -d@"./06-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process" > 06-process-create-out.txt

echo "06-process-create.sh complete"
