#! /bin/sh
# ApplyPhyToCfg.sh
#set -x

echo "Input File $1"

########################################################################################################
cdr2mask()
{
	set -- $((5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 000
	[ $1 -gt 1 ] && shift $1 || shift
	echo ${1-0}.${2-0}.${3-0}.${4-0}
}

create_envctxt(){
	envctxtdir="./Resources/www/webcfgtool/envctxt"
	envctxtfile=$envctxtdir"/ConfigData.json"
	echo "{" > $envctxtfile
	echo "\"ipaddr\":\""$1"\"," >> $envctxtfile
	echo "\"addrmsk\":\""$2"\"," >> $envctxtfile
	echo "\"gateway\":\""$3"\"," >> $envctxtfile
	echo "\"timezone\":\""$4"\"" >> $envctxtfile
	echo "}" >> $envctxtfile
	
    cat $envctxtfile
}
########################################## Retrieve Physical Net Codes ##############################
PHY_MACADDR=`ip link show dev eth0 | grep ether | awk '{print $2}'`
PHY_IPADDR=`ip addr show dev eth0 | grep -E '(inet )' | awk '{print $2}' | cut -d "/" -f 1`
PHY_MASK=$(cdr2mask `ip addr show dev eth0 | grep -E '(inet )' | awk '{print $2}' | cut -d "/" -f 2`)
PHY_GW=`ip route list | grep default | awk '{print $3}' | head -n 1`
PHY_TZ=`cat /etc/TZ`
echo "PHY_MACADDR = '$PHY_MACADDR'"
echo "PHY_IPADDR = '$PHY_IPADDR'"
echo "PHY_MASK = '$PHY_MASK'"
echo "PHY_GW = '$PHY_GW'"
echo "PHY_TZ = '$PHY_TZ'"
create_envctxt $PHY_IPADDR $PHY_MASK $PHY_GW $PHY_TZ
#####################################################################################################

#####################################################################################################
########################################## Retrieve Configuration Net Codes ##############################
CFG_PERIPHID=$(sed "s/\([,|\{|\}]\)/\1\n/g" "$1" | sed "s/\(.*\)\(\"periphid\"\s*:\s*\)\"\([[:graph:]]*\)\(\",.*\)/\3/1gp;d")
CFG_LOCALIP=$(sed "s/\([,|\{|\}]\)/\1\n/g" "$1" | sed "s/\(.*\)\(\"localip\"\s*:\s*\)\"\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)\(\",.*\)/\3/1gp;d")
echo "CFG_PERIPHID = '$CFG_PERIPHID'"
echo "CFG_LOCALIP = '$CFG_LOCALIP'"
#####################################################################################################

#####################################################################################################
########################################## Set Phy MAC Into Configuration ###########################
if [ -n "$CFG_PERIPHID" ]; then
  echo "Current periphid already set, retaining CFG_PERIPHID = '$CFG_PERIPHID' "
else
	if [ -n "$PHY_MACADDR" ]; then
	  echo "Setting current periphid as PHY_MACADDR = '$PHY_MACADDR' "
      sed -i "s/\(\s*\"periphid\"\s*:\s*\)\"\"/\1\"$PHY_MACADDR\"/" "$1"
	else
	  echo "Unable to retrieve 'PHY_MACADDR', retaining current periphid as CFG_PERIPHID = '$CFG_PERIPHID' "
	fi
fi

#####################################################################################################
########################################## Set Phy IP Into Configuration ###########################
if [ -n "$PHY_IPADDR" ]; then
	if [ "$PHY_IPADDR" != "$CFG_LOCALIP" ]; then
	  echo "Setting current localip as PHY_IPADDR = '$PHY_IPADDR' "
	  sed -i "s/\(\s*\"localip\"\s*:\s*\)\"[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\"/\1\"$PHY_IPADDR\"/" "$1"
	else
	  echo "Current localip already set, retaining CFG_LOCALIP = '$CFG_LOCALIP' "
	fi
else
  echo "Unable to retrieve 'PHY_IPADDR', retaining current ip as CFG_LOCALIP = '$CFG_LOCALIP' "
fi
#####################################################################################################

exit
