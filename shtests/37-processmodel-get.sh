#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 37-processmodel-get.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X GET \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processmodel?rs:publishedId=022-email-test.bpmn" > 37-processmodel-get-out.txt

echo "37-processmodel-get.sh complete"
