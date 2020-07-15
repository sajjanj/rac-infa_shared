#!/bin/bash
# Script Name : check_file.sh
# Description : Script that checks if file exists based  on the pattern defined as a parameter
#
# REVISION HISTORY
# Date         Name                  Comments
# 2015-xx-xx   Srinivasan Ravindran  Created new

. /home/infa_adm/.bash_profile
now=`date +%Y%m%d-%H%M%S`
log_file="/infa_shared/Scripts/logs/check_file_"$now".log"

{

directory_name=$1
interface_name=$2
file_pattern=$3
infa_folder=$4
workflow_name=$5

cd $directory_name
pwd
for i in $3*; do
	sh -x $INFA_SHARED/Scripts/start_wf.sh $infa_folder $workflow_name
	if [ $? -ne 0 ]; then	
		echo "ERR: The workflow ended in failure"; exit 10
	else
		echo "INF: The workflow completed successfully."
	fi
done
} > $log_file 2>&1 
exit 0