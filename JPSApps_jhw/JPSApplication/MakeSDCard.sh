#! /bin/sh
# multipartSDCard.sh
set -x

#######################################
#Off-topic: Disable ntpd by default 
mv /etc/init.d/ntpd /etc/init.d/__ntpd
#######################################

############################################################
#Detect u-sd card status and clean mount points
DRIVE=/dev/mmcblk0
DOIT=`fdisk -l /dev/mmcblk0 | grep ^/dev/mmcblk0 | wc -l`

umount -l -f /mnt/sd
umount -l -f /mnt/sdfast
############################################################

if [ $DOIT -lt 2 ]
then

SIZE=`fdisk -l $DRIVE | grep Disk | awk '{print $5}'`
SIZE='+'`expr $SIZE / 1024 / 1024 / 2`'M'
echo 'DISK SIZE - '$SIZE

dd if=/dev/zero of=$DRIVE bs=1024 count=1024
############## TWO PARTITION (safe vs fast) ###################
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $DRIVE
  o # clear the in memory partition table
  n # new partition
  p # primary partition (p = primary, e = extended)
  1 # partition number 1
    # default - start at beginning of disk 
  $SIZE # 7596M  = 8 GB
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  w # write the partition table
  q # and we're done
EOF

rm -p -R /mnt/sd
mkdir -p /mnt/sd
mkfs.ext4 -L "safep" ${DRIVE}p1

rm -p -R /mnt/sdfast
mkdir -p /mnt/sdfast
mkfs.ext4 -L "fastp" -O ^has_journal ${DRIVE}p2

#######################################
#Copy default resource files here ...
#######################################

else
echo 'DISK ALREADY PARTITIONED: SIZE - '$SIZE
fi

mount -t ext4 -o journal_checksum -o data=journal -o barrier=1 -o errors=remount-ro ${DRIVE}p1 /mnt/sd

mount -t ext4 -O noatime,data=writeback ${DRIVE}p2 /mnt/sdfast

exit
