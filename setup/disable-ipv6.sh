#!/bin/bash
# Disables the ipv6 protocol, for speed optimization

echo "Disabling IPV6..."

ALREADY=$(cat /etc/sysconfig/network | grep -c 'NETWORKING_IPV6=no')
if [ "$ALREADY" != "0" ]; then
	echo "Already was."
else 
	echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network
	echo "alias net-pf-10 off" >> /etc/modprobe.conf
	echo "alias ipv6 off" >> /etc/modprobe.conf
fi
echo 'Done. (After reboot)'

exit 0


