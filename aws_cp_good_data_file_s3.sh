# Script Name : aws_cp_good_data_file_s3.ksh
# Description : copy the files to AWS S3 bucket from DHVIFOAPP03 folders
# Usage       : <absolute path>/aws_cp_good_data_file_s3.sh [1(debug mode)]
# Example     : /infa_shared/Scripts/gooddata/good_data_archive.ksh [1]
# REVISION HISTORY --------------------------------------------------------------------------------
# Date			Name                Comments
# 2017-07-18	Shrikanth Kannan	Created new (Temporary solution)

. /home/infa_adm/.bash_profile

if [ $# -eq 1 ]; then
        debug=$1
else
        debug=0
fi

runtype=$1
script_nm=`basename $0|cut -d"." -f1`
dir_arch=$FTP_ARCH_OUTBOUND"/gooddata"
dir_tgt=$INFA_SHARED"/TgtFiles"
dir_tmp=$INFA_SHARED"/Temp"
dir_bin=$INFA_SHARED"/Scripts"
dir_log=$dir_bin"/logs"
#dir_wip=$INFA_SHARED"/SrcFiles/gooddata"
run_dttm=`date +%Y''%m''%d''%H''%M''%S`
file_log=$dir_log"/"$script_nm"_"$run_dttm".log"
#file_lst_DATA=$dir_tmp"/gooddata_parse_DATA.lst"
file_list=$dir_tmp"/gooddata.lst"
script_dir=$INFA_SHARED"/Scripts"

func_check_status()
{
	status_cd=$1
	checkpoint=$2
	if [ $status_cd -ne 0 ]; then
		echo "ERR: The previous step ended in failure. Aborting script execution at ["$checkpoint"]"
		exit $checkpoint
	fi
}

{
if [ -z "$runtype" ]; then
	echo "ERR: The previous step ended in failure, need to pass arguments. Aborting script execution"
	exit 20
fi

if [ $runtype == "A" ]; then

	echo -e "\nINF: Script runtime  = ["$run_dttm"]"
	echo "INF: Run by user     = [`whoami`]"
	echo "INF: Run at host     = ["$INFA_HOST"]"
	echo "INF: Script Name     = "$script_nm
	echo "INF: Script Log File = "$file_log

	echo -e "\nINF: Creating a list file for csv files at [ "$dir_tgt" ]"
	cd $dir_tgt ; ls -1 *store*.csv > $file_list

	echo -e "\nINF: copying *store*.csv files from ["$dir_tgt" ] to GoodData S3 bucket"

	for file_nm in `cat $file_list`; do
		echo "> aws cp ["$file_nm"] to gooddata S3 bucket"
		 aws s3 cp $file_nm s3://gdc-ms-cust/AIDAJ53XGEOYZAFU7Y4L6_gdc-ms-cust_Rent-A-Center/waiting/ 
		echo ">aws  s3 copy all files"
		return_code=$? ; func_check_status $return_code 20
	done

	echo -e "\nINF: Process completed successfully pushing all files to S3"
	echo -e "\nINF: Calling Archive process in ["$script_dir"] to archive all the files"

	cd $script_dir 
	. /infa_shared/Scripts/gooddata_archive.sh
	return_code=$?; func_check_status $return_code 20

else

	echo -e "\nINF: Script runtime  = ["$run_dttm"]"
	echo "INF: Run by user     = [`whoami`]"
	echo "INF: Run at host     = ["$INFA_HOST"]"
	echo "INF: Script Name     = "$script_nm
	echo "INF: Script Log File = "$file_log

	echo -e "\nINF: Creating a list file for csv files at [ "$dir_tgt" ]"
	cd $dir_tgt ; ls -rt *store_key_metrics*.csv | tail -1 > $file_list

	echo -e "\nINF: copying *store*.csv files from ["$dir_tgt" ] to GoodData S3 bucket"

	for file_nm in `cat $file_list`; do
		echo "> aws cp ["$file_nm"] to gooddata S3 bucket"
		aws s3 cp $file_nm s3://gdc-ms-cust/AIDAJ53XGEOYZAFU7Y4L6_gdc-ms-cust_Rent-A-Center/waiting/
		return_code=$? ; func_check_status $return_code 20
	done

	echo -e "\nINF: Process completed successfully pushing store_key_metric file to S3"
	echo -e "\nINF: Calling Archive process in ["$script_dir"] to archive all the files"

	cd $script_dir
	. /infa_shared/Scripts/gooddata_archive.sh
	return_code =$?; func_check_status $return_code 20

fi

} > $file_log 2>&1
