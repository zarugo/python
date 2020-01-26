#!/bin/bash
#
 
clear
echo -e "\e[3J"     # Clears scrollbar


HW=$("hostname")

######################################################################################
IPADDR=`ip addr show dev eth0 | grep -E '(inet )' | awk '{print $2}' | cut -d "/" -f 1`
HWADDR=`ip link show dev eth0 | grep ether | awk '{print $2}'`
MASK=`ip addr show dev eth0 | grep -E '(inet )' | awk '{print $2}' | cut -d "/" -f 2`
GW=`ip route list | grep default | awk '{print $3}' | head -n 1`
octet="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
ip4="^$octet\\.$octet\\.$octet\\.$octet$"
ip4_set="$octet\\.$octet\\.$octet\\.$octet"
ip_set_file_jhw="/etc/network/interfaces"
ip_set_file_rpi="/etc/dhcpcd.conf"
######################################################################################

######################################################################################
#we need those when using dhcpcd.conf because the netmask is not in octecs but in cdr
#copied from pfsense, they transform snmasks in cdr and return
######################################################################################
cdr2mask()
{
	set -- $((5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 000
	[ $1 -gt 1 ] && shift $1 || shift
	echo ${1-0}.${2-0}.${3-0}.${4-0}
}

mask2cdr()
{
	local x=${1##*255.}
	set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
	x=${1%%$3*}
	echo $(($2 + (${#x}/4) ))
}
#######################################################################################


#######################################################################################
#we use sed with regex to find and change values - args new_ip, new_msk, new_gwy
#######################################################################################
set_ip_jhw(){

	echo "# /etc/network/interfaces" > $ip_set_file_jhw
	echo "" >> $ip_set_file_jhw
	echo "auto lo" >> $ip_set_file_jhw
	echo "iface lo inet loopback" >> $ip_set_file_jhw
	echo "" >> $ip_set_file_jhw
	echo "auto eth0" >> $ip_set_file_jhw
	echo "iface eth0 inet static" >> $ip_set_file_jhw
	echo "	address $1" >> $ip_set_file_jhw
	echo "	netmask $2" >> $ip_set_file_jhw
	echo "	gateway $3" >> $ip_set_file_jhw
	echo "	dns-nameservers 208.67.222.222 208.67.220.220" >> $ip_set_file_jhw
	echo "" >> $ip_set_file_jhw
	echo "auto eth1" >> $ip_set_file_jhw
	echo "iface eth1 inet static" >> $ip_set_file_jhw
	echo "	address 172.31.0.1" >> $ip_set_file_jhw
	echo "	netmask 255.255.255.0" >> $ip_set_file_jhw
	echo "" >> $ip_set_file_jhw
	echo "auto wlan0" >> $ip_set_file_jhw
	echo "iface wlan0 inet static" >> $ip_set_file_jhw
	echo "	address 193.168.0.1" >> $ip_set_file_jhw
	echo "	netmaks 255.255.255.0" >> $ip_set_file_jhw
	echo "" >> $ip_set_file_jhw
	
    cat /etc/network/interfaces
}

#######################################################################################
#we the rpi tool to set the timezone - args new_tz
#######################################################################################
set_tz_jhw(){
	echo $1 > /etc/TZ
}


#######################################################################################
#we use sed with regex to find and change values - args new_ip, new_msk, new_gwy
#######################################################################################
set_ip_rpi(){
	sed -i -r "s:^static ip_address=$ip4_set\/[1-9]{1,2}:static ip_address=$1/$(mask2cdr $2):g" $ip_set_file_rpi
	sed -i -r "s:^static routers=$ip4_set\b:static routers=$3:g" $ip_set_file_rpi
}

#######################################################################################
#we the rpi tool to set the timezone - args new_tz
#######################################################################################
set_tz_rpi(){
	ln -fs /usr/share/zoneinfo/$1 /etc/localtime
	echo $1 > /etc/TZ
	dpkg-reconfigure -f noninteractive tzdata
}

usage(){
    clear
    echo "Usage: $0 newip newmsk newgwy timezone"
    echo "Example: $0 127.0.0.1 255.255.255.0 127.0.0.254 Europe/Paris"
    exit 1
}

 
# call usage() function if filename not supplied
	[[ $# -lt 4 ]] && usage

	new_ip=$1
	new_msk=$2
	new_gwy=$3
	new_tz=$4


	if [[ $HW == "ebb-hw-jhw-2-0" ]]
	then
		HW=jhw
		echo "Usage: configuring environment context for " $HW
		set_ip_jhw $new_ip $new_msk $new_gwy
		set_tz_jhw $new_tz
	elif [[ $HW == "raspberrypi" ]]
	then
		HW=jhw
		echo "Usage: configuring environment context for " $HW
		set_ip_rpi $new_ip $new_msk $new_gwy
		set_tz_rpi $new_tz
	else
		echo -e "\nContext " $HW " is not supported"
		exit 1
	fi

exit
