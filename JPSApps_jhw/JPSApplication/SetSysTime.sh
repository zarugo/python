#!/bin/sh
set -x

if [ $# -gt 0 ]
then
	echo "Setting time $1"
	date -s "$1"
	hwclock --utc --systohc
else
	echo "Error no input time as argument"
fi
