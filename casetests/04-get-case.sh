#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 04-get-case.sh"

CID=`cat 01-create-case-out.txt`

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X GET \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/case?rs:caseid=$CID" > 04-get-case-out.txt

echo "04-get-case.sh complete"
