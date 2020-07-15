#!/bin/bash
# Script Name         : ds_archive.sh
# Description         : Generic script to archive file(s)
# Required Parameters : Archive folder location (-a)
# 						Source file location (-s)
#						File name / all (-f)
# Optional Parameters : New archive sub-folder {yes/no} (-n)
#						Tar& Zip (yes/no) (-c)
# ------------------------------------------------------------
# REVISION HISTORY
# Date         Name                 Comments
# 2016-04-28   Sajjan Janardhanan   created new
# 2016-05-05   Sajjan Janardhanan   testing & refinements
# 2016-05-16   Sajjan Janardhanan   adding compression logic
# 2016-05-19   Sajjan Janardhanan   bug fixes
# 2016-09-28   Sajjan Janardhanan   added logging mechanism

folder_arch_flg=0; folder_src_flg=0; src_file_nm_flg=0; folder_arch_new_flg=0; compression_flg=0

now=`date +%Y%m%d%H%M%S`
file_log=${INFA_SHARED}"/Scripts/logs/ds_archive_"${now}".log"

while getopts a:s:f:c:n: opt; do
	case "$opt" in
		a)  folder_arch_flg=1
			folder_arch="$OPTARG";;
		s)  folder_src_flg=1
			folder_src="$OPTARG";;
		f)  src_file_nm_flg=1
			src_file_nm="$OPTARG";;
		n)  folder_arch_new_flg=1
			folder_arch_new="$OPTARG";;
		c)	compression_flg=1
			compression="$OPTARG";;
		\?) echo "<< invalid parameter >>"
			exit 1;;
	esac
done

if [ $folder_arch_new_flg -eq 0 ]; then
	folder_arch_new="<not requested>"
fi

if [ $compression_flg -eq 0 ]; then
	compression="<not requested>"
fi

{
	echo -e "\n*** Generic Archive Script ***"
	echo "INF: Start time [ "`date`" ]"
	echo -e "INF: Archive file datetime suffix = "$now"\n"
	echo " > Archive folder name = "$folder_arch
	echo " > Source file folder  = "$folder_src
	echo " > Source file name    = "$src_file_nm
	echo " > Archive sub-folder  = "$folder_arch_new
	echo " > Compression mode    = "$compression; echo " "

	if [ $folder_arch_flg -eq 0 ]; then
		echo "ERR: Missing Parameter (-a <archive folder location>)"; exit 20
	elif [ $folder_src_flg -eq 0 ]; then
		echo "ERR: Missing Parameter (-s <source file location>)"; exit 30
	elif [ $src_file_nm_flg -eq 0 ]; then
		echo "ERR: Missing Parameter (-f <file name / all>)"; exit 40
	fi

	echo -e "INF: The file(s) listed below will be archived to the requested location \n"
	cd $folder_src
	if [ $src_file_nm == "all" ]; then
		ls -l
		for fn in `ls -b`; do
			mv -f $fn ${fn}.${now}
			if [ $? -ne 0 ]; then
				echo "ERR: File rename ended in failure"; exit 50
			fi
		done
	else
		ls -l $src_file_nm
		mv -f $src_file_nm ${src_file_nm}.${now}
		if [ $? -ne 0 ]; then
			echo "ERR: File rename ended in failure"; exit 60
		fi
	fi

	cd $folder_src
	if [[ $compression == "yes" ]]; then ##
		echo -e "\nINF: Creating TarZip file ["$now".tz] at ["$folder_src"]"
		if [ $src_file_nm == "all" ]; then
			tar -cvzf ${now}.tz ./*
			if [ $? -ne 0 ]; then
				echo "ERR: TarZip file creation for multiple files ended in failure"; exit 70
			fi
			rm -f `ls | grep -v ".tz"`
			if [ $? -ne 0 ]; then
				echo "ERR: Archived files could not be deleted"; exit 72
			fi
		else
			tar -cvzf ${now}.tz ./$src_file_nm.$now
			if [ $? -ne 0 ]; then
				echo "ERR: TarZip file creation for a single file ended in failure"; exit 80
			fi
			rm -f ./$src_file_nm.$now
			if [ $? -ne 0 ]; then
				echo "ERR: Archived file [ $src_file_nm.$now ] could not be deleted"; exit 82
			fi
		fi
	fi

	echo -e "\nINF: The effective archive folder location is given below -"
	if [[ $folder_arch_new == "yes" ]]; then ##
		cd $folder_arch
		mkdir $now
		chmod 755 $now
		folder_arch_eff=${folder_arch}"/"${now}
	else
		folder_arch_eff=${folder_arch}
	fi
	echo "[ "$folder_arch_eff" ]"

	cd $folder_src
	if [[ $compression == "yes" ]]; then ##
		mv -f ${now}.tz $folder_arch_eff
	elif [[ $src_file_nm == "all" ]]; then
		for fn in `ls -b`; do
			mv -f $fn $folder_arch_eff
			if [ $? -ne 0 ]; then
				echo "ERR: File could not be moved to ["$folder_arch_eff"]"; exit 90
			fi
		done
	else
		mv -f ${src_file_nm}.${now} ${folder_arch_eff}
		if [ $? -ne 0 ]; then
			echo "ERR: File could not be moved to ["$folder_arch_eff"]"; exit 100
		fi
	fi

	echo -e "\nINF: Process completed successfully \n"
} > $file_log 2>&1

# --- Test Scenarios ---

#./ds_archive.sh -a $FTP_ARCH_OUTBOUND/soh -s $PMTargetFileDir -f sohbitorms.dat
#./ds_archive.sh -a $FTP_ARCH_OUTBOUND/soh -s $PMTargetFileDir -f sohbitorms_20160413.dat -c yes
#./ds_archive.sh -a $FTP_ARCH_OUTBOUND/soh -s $PMTargetFileDir -f sohbitorms_20160414.dat -c yes -n yes
#./ds_archive.sh -a $FTP_ARCH_OUTBOUND/soh -s $PMTargetFileDir -f sohbitorms_20160418.dat -n yes

#./ds_archive.sh -a $FTP_ARCH_OUTBOUND/sj_temp -s $PMTargetFileDir/sj_temp -f all
#./ds_archive.sh -a $FTP_ARCH_OUTBOUND/sj_temp -s $PMTargetFileDir/sj_temp -f all -n yes
#./ds_archive.sh -a $FTP_ARCH_OUTBOUND/sj_temp -s $PMTargetFileDir/sj_temp -f all -c yes
#./ds_archive.sh -a $FTP_ARCH_OUTBOUND/sj_temp -s $PMTargetFileDir/sj_temp -f all -c yes -n yes


