#!/bin/bash

FROM_PORT=${1:-22}
TO_PORT=${2:-32600}

echo "Redirecting incoming port $FROM_PORT to $TO_PORT."

/sbin/iptables -P FORWARD ACCEPT
echo "1" >| /proc/sys/net/ipv4/ip_forward


/sbin/iptables -t nat -A PREROUTING -i ! lo -p tcp --dport $FROM_PORT -m state --state NEW -m recent --set
/sbin/iptables -t nat -A PREROUTING -i ! lo -p tcp --dport $FROM_PORT -m state --state NEW -m recent --update --seconds 60 --hitcount 10 -j LOG --log-prefix='[Port 22 Abuse']
/sbin/iptables -t nat -A PREROUTING -i ! lo -p tcp --dport $FROM_PORT -m state --state NEW -m recent --rcheck --seconds 60 --hitcount 10 -j DROP
/sbin/iptables -t nat -A PREROUTING -i ! lo -p tcp --dport $FROM_PORT -m state --state NEW -j REDIRECT --to-port $TO_PORT
#/sbin/iptables -A PREROUTING -t nat -i eth0 -p tcp --dport $FROM_PORT -j LOG --log-prefix='[hit 22 port]'
#/sbin/iptables -A PREROUTING -t nat -i eth0 -p tcp --dport $FROM_PORT -j REDIRECT --to-port $TO_PORT

