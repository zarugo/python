#!/bin/sh

#####################################################################################################
######################################### Prepare The Environment ###################################
set -x
export LD_LIBRARY_PATH=../libs/
chmod +x JPSApplication*
appType=AppLe
#####################################################################################################

#####################################################################################################
######################################### Enable System Core Dump ###################################
ulimit -c unlimited
sysctl -w kernel.core_pattern=/mnt/sdfast/Logs/core-%e.%p.%h.%t
#####################################################################################################

#####################################################################################################
########################################## Prepare the SDCard #######################################
./MakeSDCard.sh
#####################################################################################################

#####################################################################################################
######################################## Start The Application ######################################
if [ $# -gt 1 ]
then
	 #valgrind --leak-check=yes --num-callers=10 ./JPSApplication* "$appType" "Hardware" "$1" > "$2"
	 ./JPSApplication* "$appType" "Hardware" "$1" > "$2"
elif [ $# -gt 0 ]
then
	echo "$1"
	#valgrind --leak-check=yes --num-callers=10 ./JPSApplication* "$appType" "Hardware" "$1"
	./JPSApplication* "$appType" "Hardware" "$1" > /dev/null
else
	#valgrind --leak-check=yes --num-callers=10 ./JPSApplication* "$appType" "Hardware"
	./JPSApplication* "$appType" "Hardware"
fi

exit_code=$?

echo "$(date) The JPSAplication exited with exit_code = $exit_code => " >> ./reboots.log

while [ $exit_code -ne 2 ] && [ $exit_code -ne 0 ]
do
	echo "	A Software reboot is required"
	sleep 5
	export LD_LIBRARY_PATH=../libs/
	chmod +x JPSApplication*
	
	if [ $# -gt 1 ]
	then
		#valgrind --leak-check=yes --num-callers=10 ./JPSApplication* "$appType" "Software" "$1" > "$2"
		./JPSApplication* "$appType" "Software" "$1" > "$2"
	elif [ $# -gt 0 ]
	then
		#valgrind --leak-check=yes --num-callers=10 ./JPSApplication* "$appType" "Software" "$1"
		./JPSApplication* "$appType" "Software" "$1" > /dev/null
	else
		#valgrind --leak-check=yes --num-callers=10 ./JPSApplication* "$appType" "Software"
		./JPSApplication* "$appType" "Software"
	fi

	exit_code=$?
	echo "$(date) The JPSAplication exited with exit_code = $exit_code => " >> ./reboots.log
done
#####################################################################################################

#####################################################################################################
######################################## Handle The Exit Mode #######################################
if  [ $exit_code -eq 2 ]
then
	echo "	An Hardware reboot is required"
	sleep 5
	reboot
	sleep 500
fi

echo "	A Software shutdown is required"

#####################################################################################################