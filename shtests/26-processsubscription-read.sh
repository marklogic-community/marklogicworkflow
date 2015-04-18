#!/bin/sh

# Fetch the saved and activated process subscription (alert) configuration

. ../config/webserver-settings.sh

echo "starting 26-processsubscription-read.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X GET \
    -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processsubscription?rs:name=email-sub-test" > 26-processsubscription-read-out.txt

echo "26-processsubscription-read.sh complete"
