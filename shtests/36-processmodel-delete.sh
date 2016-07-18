#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 36-processmodel-delete.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X DELETE \
    -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processmodel?rs:modelid=022-email-test&major=1&minor=0" > 36-processmodel-delete-out.txt
    
echo "36-processmodel-delete.sh complete"
