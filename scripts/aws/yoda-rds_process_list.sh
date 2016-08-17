#!/bin/bash
#
# Fetches current MySQL Processlist from each db host listed and logs them into rsyslog
# since 2014-12-15

LOG=/usr/bin/logger
lprio="local2.info"
ltag="yoda-rds"
mysqluser="loguser"
dbhost=$1

hosts=(
db1.crgedacwwjrm.us-east-1.rds.amazonaws.com
db1r.crgedacwwjrm.us-east-1.rds.amazonaws.com
db2.crgedacwwjrm.us-east-1.rds.amazonaws.com
db2r.crgedacwwjrm.us-east-1.rds.amazonaws.com
db3.crgedacwwjrm.us-east-1.rds.amazonaws.com
db3r.crgedacwwjrm.us-east-1.rds.amazonaws.com
db4.crgedacwwjrm.us-east-1.rds.amazonaws.com
db4r.crgedacwwjrm.us-east-1.rds.amazonaws.com
db5.crgedacwwjrm.us-east-1.rds.amazonaws.com
db6.crgedacwwjrm.us-east-1.rds.amazonaws.com
db6r.crgedacwwjrm.us-east-1.rds.amazonaws.com
db7.crgedacwwjrm.us-east-1.rds.amazonaws.com
misc1db.crgedacwwjrm.us-east-1.rds.amazonaws.com
stage01.crgedacwwjrm.us-east-1.rds.amazonaws.com
stage02.crgedacwwjrm.us-east-1.rds.amazonaws.com
)

trim() {
    local string="$1"
    string="${string#"${string%%[![:space:]]*}"}"   # remove leading whitespace characters
    string="${string%"${string##*[![:space:]]}"}"   # remove trailing whitespace characters
    
    echo "$string"
}

if [ "x$dbhost" != "x" ]; then
    hosts=($dbhost)
fi

for host in ${hosts[@]}; do
    #echo "$host" | $LOG -s -p $lprio -t $ltag
    mysqladmin -u $mysqluser -h $host -v PROCESSLIST | while read respline
    do
	respline=$(trim "$respline")
	if [[ "$respline" != *"---------"* && "$respline" != "" ]]; then
	    echo -e "$host $respline" | $LOG -s -p $lprio -t $ltag
	fi
    done
done

exit 0

