#!/bin/bash

BLOCK_START="##### yOda dynamic #####"
BLOCK_END="##### yOda END #####"

HOSTSFILE="/etc/hosts"
HOSTSRCFILE="/yoda/ec2/etc/hosts_yoda.txt"

# read existing yOda hosts
VARHOSTS=$(<$HOSTSRCFILE)

# empty file
>| $HOSTSRCFILE

# Generate new host file
OLD_IFS=$IFS
IFS=$'\n'

getIP() {
    fqdn=$1
    # Get the dynamic IP (dirty, I know)
    IP=`host -t a $fqdn | perl -nle '/((?:\d+\.?){4})/ && print $1' | head -n1`

    # Update the hosts file
    if test -n "$IP"; then
        eval "return_var='$IP'"
        return 0
    else
        return 1
    fi
}

for line in $VARHOSTS;
do

    ip=`echo $line | awk '{print $1}'`
    alias=`echo $line | awk '{print $2}'`
    fqdn=`echo $line | awk '{print $3}'`

    skip=0

    # check if we need to skip that line or not
    [ ${line:0:1} == '#' ] && skip=1
    [[ "$alias" == *.* ]] && skip=1
    [[ "x$ip" == "x" ]] && skip=1
    [[ "x$fqdn" == "x" ]] && skip=1

    if [ $skip == 0 ]; then
        return_var=""
        getIP $fqdn
        if [ $? == 0 ]; then
            # write new data line
            echo "$return_var   $alias  $fqdn" >> $HOSTSRCFILE
        else
            # keep untouched
            echo "$line" >> $HOSTSRCFILE
        fi
    else
        # keep untouched
        echo "Skipped line: $line"
        echo "$line" >> $HOSTSRCFILE
    fi
done

IFS=$OLD_IFS

# insert if not yet in or replace outdated content
REPLACE=`cat $HOSTSFILE | grep "$BLOCK_START"`

if [ "x$REPLACE" != "x" ]; then
    VAR=`sed -i -ne "/$BLOCK_START/ {p; r $HOSTSRCFILE" -e ":a; n; /$BLOCK_END/ {p; b}; ba}; p" $HOSTSFILE`
else
    echo $BLOCK_START >> $HOSTSFILE
    cat $HOSTSRCFILE >> $HOSTSFILE
    echo $BLOCK_END >> $HOSTSFILE
fi

echo "Finished updating all known yOda hosts in /etc/hosts"

