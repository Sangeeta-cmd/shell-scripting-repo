#!/bin/bash

<< Task-1
Disk=$(df -h /)
Hostname=$(hostname)
User=$(whoami)
Date=$(date '+%Y-%m-%d %H:%M')

echo "The Server : $Hostname | User : $User | Disk : $Disk | Date : $Date"
Task-1

<<Task-2
Service=ngnix
Status=$(sudo systemctl is-active nginx)
if [ $Status == 'active' ]; then
	echo " $Service Status is : $Status"
else
       echo " $Service Satus is $Status and it is down, not running!"
fi      
Task-2

Service=$1

if [ -z $Service ]; then
	echo "Usage: $0 <service-name>"
	exit 0
fi
Status=$(sudo systemctl is-active $Service)
echo "$Service is $Status"

