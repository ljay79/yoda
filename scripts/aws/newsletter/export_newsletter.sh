#!/bin/bash

# AWS credentials
export AWS_ACCESS_KEY_ID=**************
export AWS_SECRET_ACCESS_KEY=*************
export AWS_ACCOUNT='s3-newsletter'

# MySQL crednetials
DBNAME="newsletter"
DBUSER="awsPipeNL2015"
DBPASS="Gjkl************34"
DBHOST="db2r.xxxxxxx.rds.amazonaws.com"

S3BUCKET="s3://yoda-data/newsletter/"

BASEDIR=`dirname $(readlink -f $0)`
DATE=`date +%Y%m%d-%H`
CURRMONTH=`date +%Y%m`
RMMONTH=`date +%Y%m --date="-2 month"`

SQLFILE=$BASEDIR"/export_newsletter.sql"
SQLFILEBL=$BASEDIR"/export_blacklist.sql"
OUTFILE="/tmp/newsletter-full-$DATE.csv"
OUTFILEBL="/tmp/blacklist-$DATE.csv"

# first dump blacklist
mysql -u$DBUSER -p"$DBPASS" -h $DBHOST --database=$DBNAME -B < $SQLFILEBL | sed "s/'/\'/g;s/\"//g;s/,/ /g;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\r\n//g" > $OUTFILEBL

# s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g
mysql -u$DBUSER -p"$DBPASS" -h $DBHOST --database=$DBNAME -B < $SQLFILE | sed "s/'/\'/g;s/\"//g;s/,/ /g;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\r\n//g" > $OUTFILE

# now copy file to S3 bucket
aws s3 cp $OUTFILEBL $S3BUCKET$CURRMONTH/
aws s3 cp $OUTFILE $S3BUCKET$CURRMONTH/

rm -f $OUTFILE
rm -f $OUTFILEBL

exit 0
