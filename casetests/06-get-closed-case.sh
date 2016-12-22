#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 06-get-closed-case.sh"

CID=`cat 01-create-case-out.txt`

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X GET \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/case?rs:caseid=$CID" > 06-get-closed-case-out.txt

echo "06-get-closed-case.sh complete"
