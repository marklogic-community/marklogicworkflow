#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 00-create-case.sh"
#$WFINSU:$WFINSP
curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X PUT \
    -d@"./00-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: text/plain" \
    "http://$RESTHOST:$RESTPORT/v1/resources/case" > 00-create-case-out.txt

echo "00-create-case.sh complete"
