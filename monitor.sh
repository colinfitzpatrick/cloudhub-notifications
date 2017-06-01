#!/bin/bash

JQ=bin/jq

USERNAME=
PASSWORD=

URL=https://$USERNAME:$PASSWORD@anypoint.mulesoft.com/cloudhub/api/notifications

LASTDATE=0
if [ -f lastDate ]; then
    LASTDATE=`cat lastDate`
fi


while [ true ]; do

	sleep 5s

	#echo Looking for new Notificaitons ...

	JSON=`curl -s $URL`

	DATA=`echo $JSON | bin/jq  '.data[] | select(.createdAt > '"$LASTDATE"').domain + "," + .priority + "," + .createdAt + "," + .href + "," + .message'`	

	[ -z "$DATA" ] && continue

	#echo ... found some.

	printf '%s\n' "$DATA" | while IFS= read -r line
	do
		app=`echo $line | cut -f 1 -d, | cut -c2-`
		priority=`echo $line | cut -f 2 -d,`
		date=`echo $line | cut -f 3 -d,`
		href=`echo $line | cut -f 4 -d,`
		message=`echo $line | cut -f 5- -d,` 

		tid=`echo $message | awk -F'[=,]' '/TID/ {print $2}'`
		src=`echo $message | awk -F'[=,]' '/source/ {print $4}'`
		msg=`echo $message | awk -F'[=,]' '/Msg/ {print $7}'`

#   		echo "$app,$priority,$date,$tid,$src,\"$msg\"" #>> data.csv

		echo $msg | bin/terminal-notifier.app/Contents/MacOS/terminal-notifier -message "$msg" -title "$app" -group "$tid" -open $href -appIcon icons/icon.png -contentImage icons/$priority.png 
		sleep 1s

	done

	LASTDATE=`echo $JSON | bin/jq  '.data[0].createdAt'`
	echo $LASTDATE > lastDate

done
