#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 35-processmodel-publish-fork-simple.sh"

curl -v --anyauth --user $WFMANU:$WFMANP -X POST \
    -d "<somexml/>" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processmodel?rs:publishedId=fork-simple__1__0" > 35-processmodel-publish-fork-simple-out.txt

echo "35-processmodel-publish-fork-simple.sh complete"
