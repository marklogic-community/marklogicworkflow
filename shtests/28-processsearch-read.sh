#!/bin/sh

# Fetch the current list of process documents (see if the count is correct - 2 at this point for this process type)

. ../config/webserver-settings.sh

echo "starting 28-processsearch-read.sh"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X GET \
    -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/processsearch?rs:processname=022-email-test__1__0" > 28-processsearch-read-out.txt

echo "28-processsearch-read.sh complete"
