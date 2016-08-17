#!/bin/bash

echo " Cron $0 works..." >> /yoda/log/cron-daily.log
set -x

/usr/sbin/tmpwatch -v 24 /tmp

/bin/rm -f -v  /tmp/debug_* 

if [ -d /www ]; then
	/usr/bin/find /www -name "errors.log" -exec chmod 0777 {} \;
fi

# amazon configured instance correctly
#/yoda/setup/timezone.sh

####################
# Keep system security up2date
/usr/bin/yum update -y --security
####################

if [ -f /yoda/cron-daily.local.sh ]; then
 /yoda/cron-daily.local.sh >> /yoda/log/cron-daily.log
fi

DATE=`date`
echo "----------------------------------" >> /yoda/log/cron-daily.log
echo "$DATE: Ran cron-daily.sh" >> /yoda/log/cron-daily.log
