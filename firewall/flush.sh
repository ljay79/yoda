#!/bin/bash


iptables=$(which iptables)
if [ -z $iptables ]; then iptables=$(whereis -b iptables | awk '{print $2}'); fi
if [ -z $iptables ]; then iptables="/sbin/iptables"; fi

# Remove any existing rules from all chains
$iptables -F
$iptables -F -t nat
$iptables -F -t mangle
# Remove any pre-existing user-defined chains
$iptables -X
$iptables -X -t nat
$iptables -X -t mangle
# Zero counts
$iptables -Z

$iptables -P INPUT ACCEPT
$iptables -P OUTPUT ACCEPT
$iptables -P FORWARD ACCEPT


echo "Firewall FLUSHED."

exit 0
