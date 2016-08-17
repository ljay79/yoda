#!/bin/bash

echo
echo
echo 'What is the server hostname? '
read 
if [ "x$REPLY" = "x" ]; then
	cat /yoda/etc/hostname.conf
	echo
	exit 0
fi
echo "$REPLY" >| /yoda/etc/hostname.conf
/bin/hostname "$REPLY"
echo
echo "Hostname set."
echo
