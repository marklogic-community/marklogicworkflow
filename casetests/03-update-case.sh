#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 03-update-case.sh"

CID=`cat 01-create-case-out.txt`

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X POST \
    -d@"./03-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/case?rs:caseid=$CID" > 03-update-case-out.txt

echo "03-update-case.sh complete"
