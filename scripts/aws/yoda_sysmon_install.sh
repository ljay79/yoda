#!/bin/bash
# 
# Install script for AWS Cloud Watch Monitoring for:
#  - Disk Space Utilization
#  - CPU Utilization
#  - Memory Utilization
#  - Swap Utilization
#
# Install on node:
#   node~: scp -P 32600 log01.aws.example.com:/yoda/scripts/aws/yoda_sysmon_install.sh ./
#   node~: ./yoda_sysmon_install.sh

##############

HOST_SOURCE="log01.aws.example.com"

##############

log_daemon_msg () {
    if log_use_fancy_output; then
        RED=`$TPUT setaf 1`
        YELLOW=`$TPUT setaf 3`
        NORMAL=`$TPUT op`
    else
        RED='\033[01;31m'
        YELLOW='\033[01;33m'
        NORMAL='\033[00;39m'
    fi
 
    if [ -z "${1:-}" ]; then
        return 1
    fi
    if [ -z "${2:-}" ]; then
        echo -ne "$1:${NORMAL}"
        return
    fi
    echo -ne "$1: $2${NORMAL}"
}

log_use_fancy_output () {
    TPUT=/usr/bin/tput
    EXPR=/usr/bin/expr
    if [ -t 1 ] && [ "x${TERM:-}" != "x" ] && [ "x${TERM:-}" != "xdumb" ] && [ -x $TPUT ] && [ -x $EXPR ] && $TPUT hpa 60 >/dev/null 2>&1 && $TPUT setaf 1 >/dev/null 2>&1; then
        [ -z $FANCYTTY ] && FANCYTTY=1 || true
    else
        FANCYTTY=0
    fi
    case "$FANCYTTY" in
        1|Y|yes|true)   true;;
        *)              false;;
    esac
}


log_end_msg () {
    # If no arguments were passed, return
    if [ -z "${1:-}" ]; then
        return 1
    fi

    retval=$1

    # Only do the fancy stuff if we have an appropriate terminal
    # and if /usr is already mounted
    if log_use_fancy_output; then
        RED=`$TPUT setaf 1`
        YELLOW=`$TPUT setaf 3`
        NORMAL=`$TPUT op`
    else
        RED='\033[01;31m'
        YELLOW='\033[01;33m'
        NORMAL='\033[00;39m'
    fi

    if [ $1 -eq 0 ]; then
        echo "."
    elif [ $1 -eq 255 ]; then
        /bin/echo -e " ${YELLOW}(warning).${NORMAL}"
    else
        /bin/echo -e " ${RED}failed!${NORMAL}"
    fi
    return $retval
}

end_on_fail () {
    # If no arguments were passed, return
    if [ -z "${1:-}" ]; then
        return 1
    fi

    if [ $1 -ne 0 ]; then
        exit 1
    fi
}

run_and_check() {
	log_daemon_msg "$1"
	shift;
#	set -x
	"$@"
	result=$?
#	set +x
	log_end_msg $result
	end_on_fail $result
}

cd ~
run_and_check "downloading cloudWatchMonitoringScripts" scp -P 32600 $HOST_SOURCE:/yoda/scripts/aws/aws-scripts-mon.tar.bz2 ./
run_and_check "installing perl packeges" sudo yum install perl-Switch perl-Sys-Syslog perl-LWP-Protocol-https
run_and_check "creating group ec2-metrics-cli" sudo groupadd -g 600 ec2-metrics-cli
run_and_check "creating user ec2-metrics-cli" sudo useradd -u 600 -s /bin/false -d /opt/mon/aws-scripts-mon -g ec2-metrics-cli -M ec2-metrics-cli
run_and_check "creating /opt/mon" sudo mkdir /opt/mon
run_and_check "set permissions for /opt/mon" sudo chmod -R 755 /opt/mon
run_and_check "set owner root:root for /opt/mon" sudo chown -R root:root /opt/mon
run_and_check "checking /opt/mon" cd /opt/mon
run_and_check "extracting scripts to /opt/mon" sudo tar -xjf ~/aws-scripts-mon.tar.bz2

echo -e ""
echo -e "-----------------------------------"
echo -e "Set crontabs run:\n#crontab -u ec2-metrics-cli -e\n\nadd text:"
echo "*/5 * * * *     /opt/mon/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util --disk-path=/ --aws-credential-file=/opt/mon/aws-scripts-mon/awscreds --from-cron"
echo "your mount points"

df -h | grep "^\/dev\/"

