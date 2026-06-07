#!/bin/bash

#=================================================================================================
# Author : Sangeeta
# Description : This file checks disk  usage, memory, cpu load and network connectivity on the srver
# Usage : ./server-health-monitor.sh
# ================================================================================================

#===================
# Initial Components
#===================

THRESHOLD=80
LOGFILE=/var/log/health-check.log
REPORT_DIR=/var/log/health-report

#==================================================
# CORE FUNCTIONS
#==================================================

#log with timestamp
log(){
	local line1=$1
	local message=$2
	echo " [$(date '+%Y-%m-%d %H:%M:%S')] $line1 : $message" >> $LOGFILE
}

header-section(){
	echo $1
}

ISSUES=0
fail(){
	ISSUES=$(( ISSUES + 1 ));
}
													
setup(){
	touch $LOGFILE 2> /dev/null
	if [ $? != 0 ]; then
		echo "Try execute the command with sudo"
	fi
	mkdir -p $REPORT_DIR
	log "INFO" "--------- Health-Check Started on $(hostname) ---------"
}

#========================================================================
# check-1 : Disk Usage
# =======================================================================

check-disk(){
	header-section " Disk - Usage "
	log "INFO" "------- CHECK DEISK USAGE ----------------------"

while IFS= read -r line ; do

	MOUNT=$(echo $line | awk '{print $6}')
	USED=$( echo $line | awk '{print $5}' | tr -d '%')
	AVAILABLE=$(echo $line | awk '{print $4}')
	FILESYS=$(echo $line | awk '{print $1}')

	if [ $USED -gt $THRESHOLD ]; then
		echo " $MOUNT used $USED% ( $AVAILABLE free) - ABOVE THE THRESHOLD $THRESHOLD%"
		log "ALERT:" "$FILESYS : Mounted on $MOUNT used $USED% (available $AVAILABLE free space) - ABOVE THE THRESHOLD $THRESHOLD% "
                fail 
	elif [ $USED -gt $(( THRESHOLD - 10 )) ]; then
		 echo " $MOUNT used $USED% ( $AVAILABLE free) - approching Threshold"
		 log "WARN:" " $FILESYS : Mounted on $MOUNT used $USED% (available $AVAILABLE free space) - approaching Threshold"
        else
		  echo "[ OK ] $MOUNT used $USED% ($AVAILABLE free)"
		  log "[ OK ] " "$FILESYS- Mounted on $MOUNT used $USED% (available $AVAILABLE free space)"
	fi
done < <(df -h 2> /dev/null | tail -n +2 )
}

#=============================================================================================
# check -2 : CPU LOAD AVERAGE
# ============================================================================================
check-cpu(){
	header-section " CPU LOAD AVERAGE "
	log "INFO" "----------- CPU LOAD AVERAGE --------------------------"

	LOAD_1=$( uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}')
	LOAD_5=$( uptime | awk -F"load average:" '{print $2}' | awk -F"," '{print $2}' )
	LOAD_15=$( uptime | awk -F"load average:" '{print $2}' | awk -F"," '{print $3}' )
        CPU_CORE=$(nproc)
	UPTIME_TIME=$(uptime -p)

	echo " The Server $(hostname) | $UPTIME_TIME | CORE $CPU_CORE"
        echo " The CPU Load Average in 1min-$LOAD_1, 5min-$LOAD_5, 15min-$LOAD_15"
        log "INFO" " The Server $(hostname) is up from $UPTIME_TIME | CORE $CPU_CORE"
        log "INFO" " The CPU Load Average in 1min-$LOAD_1, 5min-$LOAD_5, 15min-$LOAD_15"
}

#===========================================================================================
# check-3 : Memory Usage
# =========================================================================================
check-memory(){
        header-section "MEMORY USAGE "
        log "INFO" "------------ MEMORY USAGE ----------------------"

           Total_Mem=$( free -h | awk 'NR==2 {print $2}' )
	   Mem_Used=$(free -h | awk 'NR==2 {print $3}')
	   Mem_Free=$(free -h | awk 'NR==2 {print $4}')
	   Available=$(free -h | awk 'NR==2 {print $7}')
	   SWAP_Total=$(free -h | awk 'NR==3 {print $2}'| tr -d "B" )

	   echo " Total Memory on Server : $Total_Mem, Used=$Mem_Used, Free=$Mem_Free, Available=$Available"
	   log "INFO" " Total Memory on Server : $Total_Mem, Used=$Mem_Used, Free=$Mem_Free, Available=$Available"

	   if [ $SWAP_Total -ne 0 ]; then
		   echo " SWAP Memory : $SWAP_Total"
		   log " INFO" " SWAP Memory : $SWAP_Total"
           else
		   echo " swap not configured"
		   log "INFO" " SWAP Not Configured on Server"
	   fi
}

#====================================================================================================
# check-4 : Service Connectivity
#====================================================================================================
check-service(){
	header-section " SERVICE CONNECTIVITY"
	log "INFO" "-------------- SERVICE CONNECTIVITY ------------------"

	SERVICE=('nginx' 'httpd' 'crond' 'docker')
	for service in ${SERVICE[@]}; do
        if ! systemctl list-unit-files | grep -q "$service.service" ; then
		echo " Service NOT FOUND"
		log "INFO" " $service is not installed : Please install"
		continue
	fi

	Status=$( systemctl is-active $service 2> /dev/null)
	enabled=$( systemctl is-enabled $service 2> /dev/null)

	if [ $Status == 'active' ]; then
		echo " $service is running - $enabled"
		log " [ OK ]" "$service is running - $enabled"
	elif [ $Status == 'inactive' ]; then
		echo " $service is stopped - enabled:$enabled"
		log "WARN" " $service DOWN -( enabled:$enabled)"
	else 
		echo " $service status is $status - enabled : $enabled"
		log "FAIL" " $service FAIL - status : $status"
		fail
	fi
done
}

#=====================================================================================
# check-5 : Network Connectivity
# ===================================================================================
check-network(){
          header-section " Network Connectivity"
          log "INFO" "-------- NETWORK CONNECTIVITY -----"
          
           Hostname=$(hostname)
           IP_Addr=$(hostname | awk -F'.' '{print $1}')

	   ping -c 1 8.8.8.8 &> /dev/null
	   if [ $? -eq 0 ]; then
		   echo "Connected to Internet(8.8.8.8) - NEWTWORK REACHABLE"
		   log "[ OK ]" "Connected to Internet(8.8.8.8) - NEWTWORK REACHABLE"
	   else
		   echo " NETWORK UNREACHABLE - NO Internet Connectivity"
		   log "FAILED" "NETWORK UNREACHABLE - NO Internet Connectivity"
		   fail
           fi

	   (host 8.8.8.8 || nslookup 8.8.8.8) &> /dev/null
	    if [ $? -eq 0 ]; then
                   echo " NEWTWORK OK - DNS working"
		   log "[ OK ]" "NEWTWORK OK - DNS Resolution (8.8.8.8 -> resolved to google.com)"
             else
                   echo " NETWORK DOWN - Check Connectivity"
                   log "FAILED" "NETWORK DOWN - DNS RESOLUTION FAILED"
		   fail
             fi
}	   

#========================================================================================================
# Summary
# =======================================================================================================
Summary(){
	header-section "********************************"
	header-section "****** Health Check Completed****"
	if [ $ISSUES -eq 0 ]; then
		echo " Health Check - Disk Usage, CPU Load, Memory, Network Connectivity All are Passed - SErver running fine"
	        log " OK " " Health Check - Disk Usage, CPU Load, Memory, Network Connectivity All are Passed - SErver running fine"
	else
		echo " Found $ISSUES issue(s) - Check Configuration "
		log "Fail" " Found $ISSUES issue(s) - Check Configuration "
	fi

	#save report
	REPORT_FILE=$REPORT_DIR/healthcheck-report-$(date "+%Y-%m-%d").log
	touch $REPORT_FILE
	echo "[$(date "+%Y-%m-%d %H:%M:%S")] [ OK ]- Monitored health check : DIsk, CPU, Memory, Network - All Passed" >> $REPORT_FILE
}

#==============================================================================================
# main 
#=============================================================================================
main(){
	setup
	check-disk
	check-cpu
	check-memory
	check-service
	check-network
	Summary

	exit $ISSUES
}

main
