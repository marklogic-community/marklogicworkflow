#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 31-processasset-delete.sh"

curl -v --anyauth --user $WFDESU:$WFDESP -X DELETE \
    -H "Accept: application/xml;*" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processasset?rs:model=021-initiating-attachment&rs:major=1&rs:minor=3&rs:asset=RejectedEmail.txt" > 31-processasset-delete-out.txt

echo "31-processasset-delete.sh complete"
