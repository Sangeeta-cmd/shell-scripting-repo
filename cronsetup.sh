#!/bin/bash

#======================================================
# Usage : ./cronsetup.sh
# Setup server-health-monitor.sh as cron job
# Run the script once to install Monitor
# The Health check script runs every 15mins
# ====================================================

Script_SRC='server-health-monitor.sh'
Script_DIST=/opt/scripts/server-health-monitor.sh
CRON_FILE=/etc/cron.d/health-monitor

echo "================ Installing CRON JOB ================"

# Creating dist file
mkdir -p /opt/scripts
echo "Created Destination file $Script_DIST"

#Coping Script to SCript_DIST
cp $Script_SRC $Script_DIST
chmod +x $Script_DIST
echo "copied script to Destination"

#Install cron job (runs every 15min)
cat > $CRON_FILE  <<CRONEOF

#This is health monitor job - runs every 15 min
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin

*/15 * * * * root $Script_DIST  >> /var/log/server-health-cron.log
CRONEOF
chmod 644 $CRON_FILE
echo " CRON file is craeted"

#run script once to install monitor
bash $Script_DIST

echo "==== INSTALLION COMPLETED ====="
echo " To view cron log -- /var/log/server-health-cron.log"
echo "Script: $Script_DIST"
echo " Cron : $CRON_FILE ( runs every 15mins)"

