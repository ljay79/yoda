#!/bin/bash

set +v

DATE=`date`

# Scripts should only run on first ever boot.
# To check this, we create a log file which inidicates if this script ran already or not.
# 

if [ -f /var/log/yoda-init-server.log ]; then
    echo "$DATE skip init script - found log file"
    echo "$DATE skip init script - found log file" >> /var/log/xxx.log
fi

touch /var/log/yoda-init-server.log
echo "$DATE exec init script - log not there"
echo "$DATE exec init script - log not there" >> /var/log/xxx.log

##############################


echo "Running INSTALL... to setup server first time."
echo 
sleep 2

#/sbin/service httpd stop
#/sbin/service mysql stop

ln -sf /yoda/bin /ybin

#./setservername.sh
#sleep 5
./timezone-ec2.sh
sleep 2
#./iptables-perm-flush.sh
#sleep 2
#./disable-ipv6.sh
#sleep 2
./setup-www.sh
sleep 2
# check what we can turn off on amazon instance
#./disable-not-needed-services.sh
#sleep 2
./backup-dir.sh
sleep 2
#./sysrestore.sh restore
#sleep 2
./initial-setup-ec2.sh
sleep 2
/sbin/service sshd restart
echo
echo "Done"
echo 'Note: logout and login again'
echo 'Note: SSH port has been changed'

set +v
