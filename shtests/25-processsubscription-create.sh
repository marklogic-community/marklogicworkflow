#!/bin/sh

# Create a process subscription (alert configuration)

. ../config/webserver-settings.sh

echo "starting 25-processsubscription-create.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X PUT \
    -d@"./25-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processsubscription" > 25-processsubscription-create-out.txt

echo "25-processsubscription-create.sh complete"
