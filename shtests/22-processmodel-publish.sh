#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 22-processmodel-publish.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X POST \
    -d "<somexml/>" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processmodel?rs:publishedId=022-email-test__1__0" > 22-processmodel-publish-out.txt

echo "22-processmodel-publish.sh complete"
