#!/bin/bash

# For LAMP Installation
# Install memcached package from YUM - only when php installation through YUM as well.
# Otherwise use /yoda/setup/install-memcached.sh to compile a nice one.
#
# Last update: 2014-06-26
# Author: Jens Rosemeier
# Interactive!

echo "[YODA] Installing 'memcached' (d)-daemon..."

YUM=$(which yum)

$YUM install memcached

# set initial config, daemon listening on locale interface only - cant be used from other servers
if [ -f /yoda/ec2/etc/memcached ]; then
    cp /etc/sysconfig/memecached /etc/sysconfig/memcached.orig
    cp -f /yoda/ec2/etc/memcached /etc/sysconfig/memcached
    chown root:root /etc/sysconfig/memcached
fi

echo "... starting memcached daemon"
service memcached start

echo "enabling autostart on boot..."
chkconfig memcached on

echo "Done."
echo 

echo "---- confirm its running ---"
netstat -an | grep 11211

echo
echo
echo "You can use 'memcached-tool localhost:11211 stats' to check its running and its stats."
echo "Bye."
