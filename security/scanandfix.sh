#!/bin/bash
# scanandfix.sh

source /yoda/bin/inc/init


chmod="/bin/chmod -v"
chown="/bin/chown -v"

$chown root:wheel /yoda/bin/copytable
$chmod 750 /yoda/bin/copytable

$chown root:wheel /yoda/sbin
$chmod 750 /yoda/sbin

$chown -R root:root /yoda/security
$chmod -R 750 /yoda/security

exit 0
