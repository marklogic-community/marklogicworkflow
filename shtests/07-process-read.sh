#!/bin/sh

. ../config/webserver-settings.sh

echo "starting 07-process-read.sh"

# TODO parse this using awk or similar from the -out document of the previous call
#STEXT = `cat 06-process-create-out.txt`

#infile='06-process-create-out.txt'

#while read line ; do
#  if [[ $line =~ ^(.*)([a-z0-9\-])(.*)$ ]] ; then
#    echo "${BASH_REMATCH[0]},${BASH_REMATCH[1]}"
#  else
#    echo "$line"
#  fi
#done < "$infile"

#THEPID= `[[ $STEXT =~ ^.*processId\>(.*)\<\/ext.* ]] && echo ${BASH_REMATCH[1]}`
#PID="ad8f7cbf-48e6-4256-bb23-2b4737d07919-2015-03-09T09:15:02.295983-07:00"
PID=`cat 06-process-create-out.txt`
#echo " THEPID: $THEPID PID: $PID"

curl -v --anyauth --user $MLADMINUSER:$MLADMINPASS -X GET \
    -H "Accept: application/xml" \
    "http://$RESTHOST:$RESTPORT/v1/resources/process?rs:processid=$PID" > 07-process-read-out.txt

echo "07-process-read.sh complete"
