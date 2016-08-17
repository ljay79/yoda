#!/bin/bash

set -v

TIMESERVER="tick.greyware.com"

echo 'Setting system timezone to UTC and syncronizing. . .'

mv -f /etc/localtime /etc/localtime-old 
ln -sf /usr/share/zoneinfo/UTC /etc/localtime 
echo 'ZONE="UTC"' > /etc/sysconfig/clock
echo 'UTC=true' >> /etc/sysconfig/clock
echo 'ARC=false' >> /etc/sysconfig/clock
rdate -s $TIMESERVER
/sbin/hwclock --systohc

set +v
