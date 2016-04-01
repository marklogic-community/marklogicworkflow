#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 00-priviligecheck-read.sh"

curl -v --anyauth --user $WFDESU:$WFDESP -X GET \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/sectest" > 00-priviligecheck-read-out.txt

echo "00-priviligecheck-read.sh complete"
