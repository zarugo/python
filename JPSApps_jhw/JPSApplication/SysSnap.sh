#!/bin/sh

today="$(date '+%Y_%m_%d_%H_%M_%S')"

mkdir "/mnt/sdfast/Logs/SysSnap$today"

(top -n1 -b)             >> "/mnt/sdfast/Logs/SysSnap$today/top"
(cat /var/log/messages)  >> "/mnt/sdfast/Logs/SysSnap$today/varlogmsg"
(dmesg)                  >> "/mnt/sdfast/Logs/SysSnap$today/dmsgmsg"
(cat /proc/meminfo)      >> "/mnt/sdfast/Logs/SysSnap$today/meminfo"
(df -h)                  >> "/mnt/sdfast/Logs/SysSnap$today/disks"
(netstat -na)            >> "/mnt/sdfast/Logs/SysSnap$today/netst"
(free -h)                >> "/mnt/sdfast/Logs/SysSnap$today/free"
