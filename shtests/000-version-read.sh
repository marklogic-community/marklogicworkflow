#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 000-version-read.sh"

curl -v --anyauth --user $WFDESU:$WFDESP -X GET \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/version" > 000-version-read-out.txt

echo "000-version-read.sh complete"
