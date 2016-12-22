#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 05-close-case.sh"

CID=`cat 01-create-case-out.txt`

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X POST \
    -d"" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/case?rs:caseid=$CID&rs:close=true" > 05-close-case-out.txt

echo "05-close-case.sh complete"
