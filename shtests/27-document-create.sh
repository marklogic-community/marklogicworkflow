#!/bin/sh

# Create a document that should fire an alert

. ../config/webserver-settings.sh

echo "starting 27-document-create.sh"

curl -v --anyauth --user $WFNONU:$WFNONP -X PUT \
    -d@"./27-payload.xml" \
    -H "Content-type: application/xml" -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/documents?uri=/some/doc.xml&collection=/test/email/sub" > 27-document-create-out.txt

echo "27-document-create.sh complete"
