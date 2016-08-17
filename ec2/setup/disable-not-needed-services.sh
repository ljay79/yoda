#!/bin/bash

echo "[YODA] Run disable-not-needed-services.sh ..."
echo "[YODA] turning off not needed services."

TURNOFF="snmpd xinetd yum-updatesd xfs rhnsd iptables gpm bluetooth cups ip6tables nrpe mcstrans"
TURNOFF="$TURNOFF pcscd restorecond netfs nfs nfslock portmap rpcgssd rpcidmapd mysql httpd"

for xx in $TURNOFF
do
    exists=$(chkconfig --list | grep -c $xx)
    if [ "$exists" != "0" ]; then
	/sbin/chkconfig $xx off
	echo "Disabling: $xx"
	/sbin/service $xx stop
    else
	echo "$xx service not even installed."
    fi
done

sleep 5
