#!/bin/bash
# Script Name : ds_update_param.sh
# Author      : Sajjan Janardhanan
# Description : Update a parameter value in T_PROCESS_PARAMETER 
# Parameters  : Name of Process, Workflow, Parameter & Parameter value
. ~/.bash_profile
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1"|"$2"|"$3"|"$4"|"$5>>$MASTER_LOG
now=`date +%Y-%m-%d_%T`
file_log="/infa_shared/Scripts/logs/ds_update_param_"$now".log"
{
echo "INF: Script name = "$0
echo "INF: Run time = "$now
if [ $# -ne 5 ]; then
	echo "ERR: Insufficient or Too many arguments"
	exit 10
else
	i_process=$1
	i_folder=$2
	i_workflow=$3
	i_paramnm=$4
	i_paramval=$5
	echo "INF: Script call details = "$0"|"$1"|"$2"|"$3"|"$4"|"$5
fi
db_passwd=`grep -iw ${DB_TNSKEY} ${FILE_PASSWD}|grep -iw ${USER_PASSWD}|cut -d"|" -f5`
if [ $i_paramval == 'sysdate' ]; then

sqlplus -s ${USER_PASSWD}/${db_passwd}@${DB_TNSKEY} <<END
whenever sqlerror exit 15
CALL SP_UPDATE_PROCESS_PARAMETER('${i_process}', '${i_folder}', '${i_workflow}', '${i_paramnm}', to_char(${i_paramval},'mm/dd/yyyy hh24:mi:ss')) ;
exit;
END

else

sqlplus -s ${USER_PASSWD}/${db_passwd}@${DB_TNSKEY} <<END
whenever sqlerror exit 15
CALL SP_UPDATE_PROCESS_PARAMETER('${i_process}', '${i_folder}', '${i_workflow}', '${i_paramnm}', '${i_paramval}') ;
exit;
END

fi

sqlplus_err=$?
if [ $spool_err -ne 0 ]; then
	echo "ERR: Spooling completed in failure"
	exit 20
else	
	echo "INF: Parameter updated successfully"
fi
} > $file_log 2>&1
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1"|"$2"|"$3"|"$4"|"$5>>$MASTER_LOG


