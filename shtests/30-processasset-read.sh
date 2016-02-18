#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 30-processasset-read.sh"

curl -v --anyauth --user $WFDESU:$WFDESP -X GET \
    -H "Accept: application/xml;*" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processasset?rs:model=021-initiating-attachment&rs:major=1&rs:minor=3&rs:asset=RejectedEmail.txt" > 30-processasset-read-out.txt

echo "30-processasset-read.sh complete"
