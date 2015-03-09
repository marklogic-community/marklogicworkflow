#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 02-processmodel-read.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X GET \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processmodel?rs:publishedId=015-restapi-tests.bpmn" > 02-processmodel-read-out.txt

echo "02-processmodel-read.sh complete"
