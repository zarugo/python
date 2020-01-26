#!/bin/sh
# set -x
# Shell script to monitor or watch the disk space
# It will send an email to $ADMIN, if the (free available) percentage of space is >= 90%.
# -------------------------------------------------------------------------
# Set admin email so that you can get email.
ADMIN="root"
# set alert level 90% is default
ALERT=90
# Exclude list of unwanted monitoring, if several partions then use "|" to separate the partitions.
# An example: EXCLUDE_LIST="/dev/hdd1|/dev/hdc5"
EXCLUDE_LIST=""
#
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#
function main_prog() {
while read output;
do
#echo $output
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1)
  partition=$(echo $output | awk '{print $2}')
  if [ $usep -ge $ALERT ] ; then
     echo "Running out of space \"$partition ($usep%)\" on server $(hostname), $(date) Alert: Almost out of disk space $usep%" >> space.log
	 if [ $partition == "/mnt/sdfast" ] ; then
		rm -R "$partition/Logs"
		echo "Cleaning out of space \"$partition ($usep%)\" on server $(hostname)" >> space.log
	 fi
  fi
done
}

while :
do
	if [ "$EXCLUDE_LIST" != "" ] ; then
	  df -h | grep -vE "^Filesystem|tmpfs|cdrom|${EXCLUDE_LIST}" | awk '{print $5 " " $6}' | main_prog
	else
	  df -h | grep -vE "^Filesystem|tmpfs|cdrom" | awk '{print $5 " " $6}' | main_prog
	fi
	sleep 5
done
