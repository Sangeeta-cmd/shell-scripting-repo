#!/bin/bash

<<Task-1
Loop through multiple services and check all

Services=("nginx" "docker" "sshd" "httpd")
for service in ${Services[@]}; do
	Status=$( sudo systemctl is-active $service 2>/dev/null)
	if [ $Status = 'active' ]; then
		echo "[ OK ] $service is running...."
	else
		echo "[ FAILED ] $service : $Status"
	fi

done

Task-1



<<Task-2
Check exit code $? — did the last command succeed?
Every command returns 0 (success) or non-zero (failure).

ping -c 1 myname &> /dev/null  #-c tells that how many counts of packest to be printed.
if [ $? -eq 0 ]; then
	echo "NETWORK REACHABLE"
else
	echo "NETWORK UNREACHABLE - Check Connectivity"
fi

Task-2



<<Task-3
Write output to a log file with timestamps
Task-3

LOGFILE=/dev/logfile

log(){
	echo " $(date '+%Y-%m-%d %H:%M:%S') $1" >> $LOGFILE

}

log "Script STARTED"
log "Disk Usage of / : $(sudo df -h / | awk 'NR==2 {print $5}' )"
log "Script CLOSED"
