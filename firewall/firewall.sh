#!/bin/bash

# Made by noah with help from many security websites

DEFAULT_POLICY="DROP"

PORTS_PRIVATE="53,111,825,841,871,889,2049"

PORTS_PUBLIC="21,22,80,81,443,3306,32600,32601,32605"

PORTS_PUBLIC_MORE="22,23,25,26,110,143,465,843,993,1311"

PORTS_NFS="932,935,946,949,958,1017,111,2049,39225,46498"
PORTS_DELL="5986,5989"

PORTS_PUBLIC_EXTRA="${PORTS_NFS},${PORTS_DELL}"

HOSTNAME=$(/bin/hostname)
FROM_WORLD="-i eth0"
FROM_LAN="-i eth1"
ANYWHERE="0.0.0.0/0"
LAN_NETMASK="172.16.0.0/12"


WAN_IP=""
SAFETY="yes"

##############################################################

if [ ! -z ${1} ]; then
	if [ "$1" = "-f" ]; then
		echo
		echo '(for REALS now)'
		echo
		SAFETY="no"
	fi
fi


##############################3

echo 
echo

if [ $DEFAULT_POLICY != "DROP" ]; then 
DEFAULT_POLICY="ACCEPT"
fi

POLICY="$DEFAULT_POLICY"

iptables=$(which iptables)
_IFS=$IFS

if [ -f /yoda/bin/inc/init ]; then source /yoda/bin/inc/init; fi

if [ -z $WAN_IP ]; then
	if [[ $HOSTNAME = *.* ]]; then
		WAN_IP=`resolveip -s $HOSTNAME`
	else
		WAN_IP="?"
	fi
	if [[ ! $WAN_IP = [0-9]* ]]; then
		WAN_IP=$(/sbin/ifconfig  | grep 'inet addr:'| grep -v -P '127.0.0.1|192\.168\.|172\.31\.|10\.0\.0' | cut -d: -f2 | awk '{print $1}' | head -n1)
	fi
fi

if [ -z $WAN_IP ]; then
	myerror "Cannot detect IP address."
	exit 1
fi

mymsg "Initializing yoda firewall"
sleep 2
echo -e "${YELLOW}Hostname:\t\t${BLUE}${HOSTNAME}"
echo -e "${YELLOW}External IP Address:\t${BLUE}$WAN_IP${NC}"
echo -e "${YELLOW}Lan Netmask:\t\t${BLUE}$LAN_NETMASK"
sleep 2
echo -e "${YELLOW}Default policy:\t\t${RED}$DEFAULT_POLICY${NC}"
sleep 5

echo_port ()
{	
	local P=$1
	local C=${YELLOW}
	if [ -n $2 ]; then
		C=$2
	fi
	local PN=`cat /etc/services | grep -P "\s${1}/tcp" | awk '{print $1}'`
	if [ -z $PN ]; then
		PN="?"
	fi
	echo -e "${C}${P}${NC}\t(${BLUE}${PN}${NC})"
}

if [ $POLICY = "ACCEPT" ]; then

	echo -e "\n${YELLOW}Blocked ports:${NC}"
	IFS=","
	for port in $PORTS_PRIVATE; do
		echo_port $port $RED
	done
	IFS=$_IFS

fi

if [ $POLICY = "DROP" ]; then

	echo -e "\n${YELLOW}Allowed ports:${NC}"
	sleep 2
	IFS=","
	for port in $PORTS_PUBLIC; do
		echo_port $port $GREEN
	done
	echo
	sleep 2
	echo -e "\n${YELLOW}And:${NC}"	
	for port in $PORTS_PUBLIC_EXTRA; do
    echo_port $port $GREEN
  done
	IFS=$_IFS
	sleep 2
fi

#--------------------------
# Flushing.
#--------------------------

mymsg "Flushing..."

#### Remove any existing rules from all chains
$iptables -F
$iptables -F -t nat
$iptables -F -t mangle

#### Remove any pre-existing user-defined chains
$iptables -X
$iptables -X -t nat
$iptables -X -t mangle

#### Zero counts
$iptables -Z

$iptables -P INPUT ACCEPT
$iptables -P OUTPUT ACCEPT
$iptables -P FORWARD DROP

#------------------------

# Enable source address spoofing protection
echo 1 >| /proc/sys/net/ipv4/conf/all/rp_filter

# Log packets with impossible source addresses
echo 1 >| /proc/sys/net/ipv4/conf/all/log_martians

# Enable TCP SYN cookie protection from SYN floods
echo 1 >| /proc/sys/net/ipv4/tcp_syncookies

sleep 2

#-------------------------------------------------------------------
# Creating some custom chains to -j into for logging suspecious stuff
#------------------------------------------------------------------

mymsg "Creating chains..."

$iptables -N Blacklist
$iptables -N Whitelist

#### Useful chain - Log Portscans
$iptables -N LogReject
$iptables -A LogReject -p tcp -m limit --limit 1/s -j LOG --log-prefix "[TCP Hacking!] "
$iptables -A LogReject -p udp -m limit --limit 1/s -j LOG --log-prefix "[UDP Hacking!] "
$iptables -A LogReject -f -m limit --limit 1/s -j LOG --log-prefix "[Fragmented Packet!] "
$iptables -A LogReject -p tcp -j REJECT --reject-with tcp-reset
$iptables -A LogReject -j REJECT

sleep 2

#### Useful chain - Log Hackers
$iptables -N LogReject2
$iptables -A LogReject2 -m limit --limit 1/s -j LOG --log-prefix "[Port scanning?] "
$iptables -A LogReject2 -p tcp -j REJECT --reject-with tcp-reset
$iptables -A LogReject2 -j REJECT

sleep 2

#### Useful chain - Log Hackers
$iptables -N LogReject3
$iptables -A LogReject3 -m limit --limit 1/s -j LOG --log-prefix "[Port flooding?] "
$iptables -A LogReject3 -p tcp -j REJECT --reject-with tcp-reset
$iptables -A LogReject3 -j REJECT

sleep 2

#### Useful chain - Log Drops
$iptables -N DROP_Log			
$iptables -A DROP_Log -m limit --limit 1/s -j LOG --log-prefix "[FORCED DROP] " --log-level=info
$iptables -A DROP_Log -j DROP

sleep 2

#--------------------------------------------------
# TABLE - ICMP Table
#-------------------------------------------------
$iptables -N ICMPs
$iptables -A ICMPs -p icmp -m icmp --icmp-type 8 -j DROP 
$iptables -A ICMPs -j ACCEPT

sleep 2

#--------------------------------------------------
# TABLE - CHECK FOR FUCKED UP SHIT
#-------------------------------------------------
$iptables -N DustFilter
$iptables -A DustFilter -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,PSH,URG -j LogReject
$iptables -A DustFilter -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j LogReject
$iptables -A DustFilter -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j LogReject
$iptables -A DustFilter -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j LogReject

sleep 2

#--------------------------------------------------
# The actual INPUT chain.
#-------------------------------------------------

mymsg "Creating INPUT chain..."

### Accept LAN always
$iptables -A INPUT -i ! eth0 -j ACCEPT
$iptables -A INPUT -i lo -j ACCEPT
$iptables -A INPUT -i eth1 -j ACCEPT
$iptables -A INPUT -s 127.0.0.1 -j ACCEPT
$iptables -A INPUT -d 127.0.0.1 -j ACCEPT
$iptables -A INPUT -s $WAN_IP -j ACCEPT
$iptables -A INPUT -s $LAN_NETMASK -j ACCEPT
$iptables -A INPUT -d $LAN_NETMASK -j ACCEPT
$iptables -A INPUT -s 10.0.0.0/8 -j ACCEPT
$iptables -A INPUT -d 10.0.0.0/8 -j ACCEPT
$iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT
$iptables -A INPUT -d 192.168.0.0/16 -j ACCEPT
$iptables -A INPUT -p icmp -j ICMPs

# THIS IS TEMPORARY!
$iptables -A INPUT -p udp -j ACCEPT

# No fragments
$iptables -A INPUT -f -j LogReject


# If we Know you come on in!
$iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Otherise
$iptables -A INPUT -m state --state INVALID -j LogReject
$iptables -A INPUT -p tcp ! --syn -m state --state NEW -j LogReject
# Clean up
$iptables -A INPUT -p tcp -j DustFilter

# For your use
$iptables -A INPUT -j Blacklist
$iptables -A INPUT -j Whitelist

sleep 3

#--------------------------------------------------
# TRAP HACKERS

if [ $POLICY = "ACCEPT" ]; then
	### Private Ports - Log and Reject
	$iptables -A INPUT -p tcp -m multiport --dports $PORTS_PRIVATE -j LogReject2
else
	### Public Ports - Accept
	$iptables -A INPUT -p tcp -m multiport --dports $PORTS_PUBLIC -j ACCEPT
	$iptables -A INPUT -p tcp -m multiport --dports $PORTS_PUBLIC_EXTRA -j ACCEPT
fi

### Rate Limiting - Prevent bot password cracking on ssh
#$iptables -A INPUT -p tcp -m multiport --dports 22,32600 -m state --state NEW -m recent --set
#$iptables -A INPUT -p tcp -m multiport --dports 22,32600 -m state --state NEW -m recent --update --seconds 60 --hitcount 20  -j LogReject2

if [ $POLICY = "DROP" ]; then
	$iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
	$iptables -A INPUT -p tcp -j DROP
	echo
	echo -e "${WHITE}Final ${RED}DROP${WHITE} rule added"
fi

sleep 2


if [ "$SAFETY" = "no" ]; then
	mymsg "Firewall installed."
	exit 0
fi

echo -e "${RED}If you can read this, hit ${WHITE}CONTROL-C${RED}now."
sleep 1
echo -e "${RED}In about 30 seconds all iptables will be flushed.${NC}"
sleep 10
echo 20
sleep 10
echo 10
sleep 5
echo 5
sleep 5 

$iptables -F
$iptables -F -t nat
$iptables -F -t mangle
$iptables -X
$iptables -X -t nat
$iptables -X -t mangle
$iptables -Z
$iptables -P INPUT ACCEPT
$iptables -P OUTPUT ACCEPT
$iptables -P FORWARD DROP

echo -e "${GREEN}Tables flushed again. To skip this safety feature,"
echo -e "run ${WHITE}$0${GREEN} with argument ${YELLOW}-f${NC}."

mymsg "Done."

exit 0
