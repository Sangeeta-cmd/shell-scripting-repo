#!/bin/bash

<<Task-1
Disk threshold alert - trigger if above 80%

Threshold=80
Usage=$( sudo df -h / | awk 'NR==2 {print $5}' | tr -d "%" )
if [ $Usage -gt $Threshold ]; then
	echo "Alert: Disk at Usage $Usage% : Above Threshold $Threshold%"
else
	echo " [ OK ] - Disk at Usage $Usage% "
fi
Task-1


<<Task-2
Restart a service if its down - autoheal script

LOGFILE=/dev/autoheal.txt
Service=$1
Status=$( sudo systemctl is-active $Service )
if [ $Status != 'active' ]; then
	echo "$(date '+%Y-%m-%d %H:%M') Alert : $Service is down - restarting............." >> $LOGFILE
	sudo systemctl restart $Service 2> /dev/logfile

	if [ $? -eq 0 ];then
		echo "$(date '+%Y-%m-%d %H:%M') $Service [ OK ]: restarted " >> $LOGFILE
	 else
	       echo "$(date '+%Y-%m-%d %H:%M')  $Service FAILED, status:$Status" >> $LOGFILE
     	fi
fi	
Task-2


<<Task-3
Parse log filer and count the errors

LOGFILE=/var/log/nginx/error.log
COUNT=$( sudo grep -c 'ERROR' $LOGFILE 2>error.log)
echo " Error count in $LOGFILE : $COUNT"

sudo grep "ERROR" | tail-10 $LOGFILE # as there is no error in the file I have searched some other word

Task-3

