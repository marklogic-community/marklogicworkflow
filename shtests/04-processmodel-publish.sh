#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 04-processmodel-publish.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X POST \
    -d "<somexml/>" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processmodel?rs:publishedId=015-restapi-tests__1__2" > 04-processmodel-publish-out.txt

echo "04-processmodel-publish.sh complete"
