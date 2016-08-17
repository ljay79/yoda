#!/bin/bash
# Global after-boot script.
# Server SPECIFIC scripts go in: /yoda/etc/startup/rclocal-local.sh 
# DO NOT EDIT #

touch /var/lock/subsys/local

if [ -f /yoda/etc/hostname.conf ]; then
	HOSTNAME=$(cat /yoda/etc/hostname.conf)
	/bin/hostname "$HOSTNAME"
	export HOSTNAME
fi

SERVER=$(/bin/hostname -s)
export SERVER

/sbin/service syslog start

sleep 1

/bin/logger 'Running /yoda/etc/startup/rclocal.sh'

/sbin/service sshd start

/yoda/setup/timezone.sh

/yoda/firewall/flush.sh

/yoda/bin/quickstats

/sbin/service sendmail start

if [ -f /yoda/etc/startup/rclocal-local.sh ]; then
	. /yoda/etc/startup/rclocal-local.sh
elif [ -f /yoda/etc/startup/startup.sh ]; then
	. /yoda/etc/startup/startup.sh
fi
