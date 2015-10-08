#!/bin/sh

# Create a process asset

. ../config/webserver-settings.sh

echo "starting 29-processasset-create.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X PUT \
    -d@"./modules/workflowengine/assets/021-initiating-attachment/1/2/RejectedEmail.txt" \
    -H "Content-type: text/plain" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processasset?rs:model=021-initiating-attachment&rs:major=1&rs:minor=3&rs:asset=RejectedEmail.txt" > 29-processasset-create-out.txt

echo "29-processasset-create.sh complete"
