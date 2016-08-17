#!/bin/bash
# Global after-boot script.
# Server SPECIFIC scripts go in: /yoda/rclocal-local.sh 
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

/bin/logger 'Running /yoda/rclocal.sh'

/sbin/service sshd start

/yoda/setup/timezone.sh

/yoda/firewall/flush.sh

/yoda/bin/quickstats

/sbin/service sendmail start

if [ -f /yoda/rclocal-local.sh ]; then
	. /yoda/rclocal-local.sh
elif [ -f /yoda/startup.sh ]; then
	. /yoda/startup.sh
fi
