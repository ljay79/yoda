#!/bin/bash

# Set proper hostname based from user-date set on EC2 instances
echo "[YODA] Run sethostname.sh ..."

new_hostname=""
new_fqdn=""

trim() {
    local var=$@
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}	

# Finds "hostname: xxxx" and "fqdn: xxxx.yyyy.zzz" in string
# ONLY when it is part of "#cloud-cinfig" in aws yaml syntax
function explode_args {
    string=$1
    OLD_IFS=$IFS
    IFS=$'\n'
    cloud_config=0
    host_found=0
    fqdn_found=0

    for row in ${string//\\n/ }; do

	if [[ "$row" = "#cloud-config" ]]; then
	    cloud_config=1
	    continue
	elif [[ "$cloud_config" = 0 ]]; then
	    continue
	fi

	if [[ "$row" =~ .*: ]]; then
	    VARNAME=${row%%:*}
	    VARVAL=${row#*:}
	    # delete spaces around the var name and value (using extglob)
	    VARNAME=`trim $VARNAME`
	    VARVAL=`trim $VARVAL`
	fi

	# set hostname var
	if [ "$VARNAME" = "hostname" -a "$host_found" = 0 ]; then
	    eval "new_$VARNAME=$VARVAL"
	    host_found=1
	fi
	
	# set fqdn var
	if [ "$VARNAME" = "fqdn" -a "$fqdn_found" = 0 ]; then
	    eval "new_$VARNAME=$VARVAL"
	    fqdn_found=1
	fi

    done

    IFS=$OLD_IFS
}

# grep user-data from aws ec2 instance meta data
UDARGS=`curl -s http://169.254.169.254/latest/user-data`

if [[ "$UDARGS" != "" ]]; then
    explode_args "$UDARGS"
else
    exit 0
fi

# only set hostname if we actually found valid values
if [[ "$new_fqdn" != "" ]]; then
    # split it into just domain and plain hostname
    DOMAIN=${new_fqdn/${new_hostname}./}
    HOSTNAME=${new_hostname/${DOMAIN}/}
    
    # set new domainname
    domainname $DOMAIN
else
    HOSTNAME="$new_hostname"
fi

if [[ "$HOSTNAME" != "" ]]; then
    # set new hostname
    hostname $HOSTNAME
fi

# store new hostname to /yoda/ec2/etc/hostname.conf for reboot config
echo "$HOSTNAME" > /yoda/ec2/etc/hostname.conf

echo "[YODA] Set new hostname [$HOSTNAME]"
