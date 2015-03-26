#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 10-processqueue-read.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X GET \
    -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processqueue?rs:queue=Editors" > 10-processqueue-read-out.txt

echo "10-processqueue-read.sh complete"
