#!/bin/bash

iptables=$(which iptables)
iptables_save=$(which iptables-save)

$iptables -F
$iptables -X
$iptables -Z

$iptables -P INPUT ACCEPT
$iptables -P OUTPUT ACCEPT
$iptables -P FORWARD ACCEPT

$iptables_save
$iptables_save >| /etc/sysconfig/iptables

/sbin/service iptables restart

iptables=$(which ip6tables)
iptables_save=$(which ip6tables-save)

$iptables -F
$iptables -X
$iptables -Z

$iptables -P INPUT ACCEPT
$iptables -P OUTPUT ACCEPT
$iptables -P FORWARD ACCEPT

$iptables_save
$iptables_save >| /etc/sysconfig/ip6tables

/sbin/service ip6tables restart


