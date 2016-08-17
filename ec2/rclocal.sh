#!/bin/bash
# Global after-boot script.
# Server SPECIFIC scripts go in: /yoda/rclocal-local.sh 
# DO NOT EDIT #

if [ -f /yoda/ec2/etc/hostname.conf ]; then
	HOSTNAME=$(cat /yoda/ec2/etc/hostname.conf)
	/bin/hostname "$HOSTNAME"
	export HOSTNAME
fi

SERVER=$(/bin/hostname -s)
export SERVER

/usr/bin/logger '[YODA] Running /yoda/ec2/rclocal.sh'

# started through amazon cloud-init
#/sbin/service sshd restart

# configured correct by amazon cloud-init
#/yoda/ec2/setup/settimezone.sh

# configured empty by amazon cloud-init
#/yoda/firewall/flush.sh

PHP_INSTALLED=$(yum list installed | egrep -i 'php')
if [ "x$PHP_INSTALLED" != "x" ]; then
    /yoda/bin/quickstats
fi

# started through amazon cloud-init
/sbin/service sendmail restart

/yoda/sbin/yum-autoupdate

/yoda/scripts/update_hostips.sh

if [ -f /yoda/rclocal-local.sh ]; then
	. /yoda/rclocal-local.sh
fi
