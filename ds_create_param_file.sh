#!/bin/bash
# Script Name : ds_create_param_file.sh
# Author      : Sajjan Janardhanan
# Description : Create Dynamic Parameter Files
# Parameters  : Process Name & absolute path of the parameter file 
. ~/.bash_profile
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1"|"$2>>$MASTER_LOG
now=`date +%Y-%m-%d_%T`
file_log="/infa_shared/Scripts/logs/ds_create_param_file_"$now".log"
{
echo "INF: Script name = "$0
echo "INF: Run time = "$now
if [ $# -ne 2 ]; then
	echo "ERR: Insufficient or Too many arguments"
	exit 1
else
	i_process=$1
	i_file_param=$2
fi
echo "INF: Parameter (process) = "$i_process
echo "INF: Parameter (parameter file) = "$i_file_param
db_passwd=`grep -iw ${DB_TNSKEY} ${FILE_PASSWD}|grep -iw ${USER_PASSWD}|cut -d"|" -f5`
return_value=`sqlplus -s ${USER_PASSWD}/${db_passwd}@${DB_TNSKEY} <<SQL+
whenever sqlerror exit -1
set linesize 1300 trimspool on heading off echo off term off pagesize 0
set feedback off timing off verify off
set serveroutput on size 1000000
spool ${i_file_param};
select param_nm || param_val as param_ln from (
select parameter_name as param_nm, 
case parameter_value when 'N/A' then null else '=' || parameter_value end as param_val
from t_process_parameter where 1=1
and process_name='${i_process}'
order by parameter_seq) ;
spool off;
exit;
SQL`
spool_err=$?
sp_err=`echo $return_value|grep -l "SP2-"|wc -c`
ora_err=`echo $return_value|grep -l "ORA-"|wc -c`
if [ $sp_err -gt 0 ] || [ $ora_err -gt 0 ] || [ $spool_err -ne 0 ]; then
	echo "ERR: Spooling completed in failure - "${return_value}
	exit 2
else	
	echo "INF: The parameter file has been created successfully"
fi
} > $file_log 2>&1
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1"|"$2>>$MASTER_LOG