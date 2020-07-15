#!/bin/bash
# Script Name : star_wf.sh
# Description : Wrapper script to run a PowerCenter workflow
#
# REVISION HISTORY
# Date         Name                  Comments
# 2015-xx-xx   Srinivasan Ravindran  Created new
# 2015-06-02   Sajjan Janardhanan    Refined script to make use of encrypted password & logging
# 2015-06-03   Sajjan Janardhanan    Made use of environment variables for Domain & Int-Service & logic to purge log files
# 2015-07-09   Sajjan Janardhanan    Minor updates
# 2016-12-01   Sajjan Janardhanan    Removed PURGE logic, cuz it was causing delays for 3PL & SupplierEDI processes
. ~/.bash_profile
now=`date +%Y%m%d-%H%M%S`
log_file=$INFA_SHARED"/Scripts/logs/start_wf_"$now".log"
{
	if [ $# -ne 2 ]; then
		echo "ERR: Insufficient number of parameters."; exit 10
	fi
	folder=$1
	workflow=$2
	echo "INF: Running the following command"
	$INFA_HOME/server/bin/pmcmd startworkflow -d $INFASVC_DOM -sv $INFASVC_INT -u $INFA_PMUSER -pv INFA_PMPASS -f $folder -wait $workflow
	if [ $? -ne 0 ]; then	
		echo "ERR: The workflow ended in failure"; exit 20
	else
		echo "INF: The workflow completed successfully."
	fi
	# echo "INF: List of LOG files being purged in ["$INFA_SHARED/Scripts/logs"]"
	# cd $INFA_SHARED/Scripts/logs
	# find ./start_wf*.log -mtime +7
	# rm -f `find ./start_wf*.log -mtime +7`
	# if [ $? -ne 0 ]; then
		# echo "ERR: Purge operation ended in failure"; exit 30
	# fi
	echo "INF: Script completed successfully"
} > $log_file 2>&1 
exit 0
