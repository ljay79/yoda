#!/bin/bash

# Initial (first boot ever) yoda Install script for any new machine.
# It will perform all default initialisation like:
# set hostname permanently, set our custom bash profile, timezone setup, ssh config,
# yum package cleanup and install of few basics we require frequently (minimal)
# 
# As we let this INSTALL script being executed through cloud-init (from user-data) or by rc.local
# we need to handle our self to validate its the first boot ever or not.

# For our 'kitchen' machine we do not want to install anything.
# 'kitchen' is our plain AMI to bake plain AMIs with nothing then a yoda install and init setup on first boot.
if [ "$HOSTNAME" = "kitchen" ]; then
    # Dont do anything on kitchen!!!!
    exit 0
fi


#### GO ####


DIR="/yoda/ec2/setup"
cd "$DIR"

DATE=`date`
LOG="/yoda/log/install.log"
LOCK="/yoda/ec2/etc/installed.lock"

mkdir -p /yoda/log
mkdir -p /yoda/ec2/etc

# Scripts should only run on first ever boot.
# To check this, we create a log file which inidicates if this script ran already or not.
if [ -f $LOCK ]; then
    echo "$DATE [YODA] INSTALL.sh skipped - system already initialized/not first boot"
    exit 0
fi

# create lock file to never runs this script again
touch $LOCK
chmod 400 $LOCK

##############################

echo "############ [YODA] initial INSTALL - $DATE ###########"
echo "############ [YODA] initial INSTALL - $DATE ###########" >> $LOG

echo "[YODA] Running INSTALL... to setup server first time." >> $LOG

/sbin/service httpd stop
/sbin/service mysql stop

ln -sf /yoda/bin /ybin
ln -sf /yoda/etc/profile /etc/profile.d/yoda.sh

# exec
sh sethostname.sh
echo "[YODA] hostname set done..." >> $LOG

./cfg-sshd.sh

sh add-users.sh

# include
./settimezone.sh
./disable-not-needed-services.sh

sleep 1

./backup-dir.sh

./initial-setup.sh

# for the log
echo "[YODA] Note: logout and login again" >> $LOG
echo "[YODA] Note: SSH port has been changed" >> $LOG
echo "################# [YODA] Done - $DATE #################" >> $LOG

# for the prompt which executed that file
echo "[YODA] Note: logout and login again"
echo "[YODA] Note: SSH port has been changed"

echo "################# [YODA] Done - $DATE #################"

