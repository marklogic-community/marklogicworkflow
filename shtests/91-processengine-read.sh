#!/bin/sh

# Fetch the current list of running processes only (not dead or errored ones)

. ../config/webserver-settings.sh

echo "starting 91-processengine-read.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X GET \
    -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processengine" > 91-processengine-read-out.txt

echo "91-processengine-read.sh complete"
