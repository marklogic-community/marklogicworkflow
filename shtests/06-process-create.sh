#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 06-process-create.sh"
#$WFINSU:$WFINSP
curl -v --anyauth --user $WFINSU:$WFINSP -X PUT \
    -d@"./06-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: text/plain" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process" > 06-process-create-out.txt

echo "06-process-create.sh complete"
