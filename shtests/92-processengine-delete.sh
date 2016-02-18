#!/bin/sh

# Fetch the current list of running processes only (not dead or errored ones)

. ../config/webserver-settings.sh

echo "starting 92-processengine-delete.sh"

curl -v --anyauth --user $WFADMU:$WFADMP -X DELETE \
    -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processengine" > 92-processengine-delete-out.txt

echo "92-processengine-delete.sh complete"
