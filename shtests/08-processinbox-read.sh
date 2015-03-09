#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 08-processinbox-read.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X GET \
    -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processinbox" > 08-processinbox-read-out.txt

echo "08-processinbox-read.sh complete"
