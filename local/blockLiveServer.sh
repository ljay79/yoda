#!/bin/bash
# Totally ensure, this test servers does NOT interfer any how with the live system
# so far its safe to block Ports: 80,443,3306, 3301,3302,3303,3304
# 2012-09-10, Jens Rosemeier

# List of all live server IPs we want to block - over eth0/1
LIVESERVER_IP="
172.31.202.182
172.31.202.251
172.31.202.30
172.31.202.73
172.31.202.181
172.31.202.246
172.31.202.34
172.31.202.31
172.31.202.183
172.31.202.136
172.31.202.32
172.31.202.146
172.31.151.141
207.150.202.182
207.150.202.251
207.150.202.30
207.150.202.73
207.150.202.246
207.150.202.181
207.150.202.34
207.150.202.31
"

for ip in $LIVESERVER_IP ; do
    echo "un/block IP: $ip"
    # BLOCK outgoing traffic to live server IPs
    /sbin/iptables -I OUTPUT -p tcp -m multiport --dports 80,443,3306,3301,3302,3303,3304 -j DROP -d $ip

    # UNBLOCK
    #/sbin/iptables -D OUTPUT -p tcp -m multiport --dports 80,443,3306,3301,3302,3303,3304 -j DROP -d $ip
done

exit 1
