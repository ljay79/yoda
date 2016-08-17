#!/bin/bash
#
# !For the Free Lite version only!
# !If subscription is available, use documented autoupdate, see: http://dev.maxmind.com/geoip/geoipupdate/
# MaxMind is updating the Free GeoIp databases once every months on the first thuesday.
# This Script is called by a cronjob every day.
# Checks if we are on the first wednesday of the month, when yes we do the update.
# File: GeoLiteCity.dat
#
# Author:       Jens Rosemeier
# Since:        2012-05-07, 2014-01-08
#

DAYOFWEEK=`date +"%u"`
DAYOFMONTH=`date +"%d"`
#make it a int
let DAYOFWEEK=$DAYOFWEEK+0
let DAYOFMONTH=$DAYOFMONTH+0

if [[ $DAYOFMONTH -gt 7 || ! $DAYOFWEEK -eq 3 ]]; then
    # Its not first Wednesday of month, exit
    exit 0
fi

echo "updating..."


# do GeoIP DB update
# Used for Free DB update

cd /tmp
wget -q http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
if [ -f GeoLiteCity.dat.gz ]
then
    gzip -d -f GeoLiteCity.dat.gz
    rm -f /usr/share/share/GeoIP/Geo-LiteCitydat
    mv -f GeoLiteCity.dat /usr/local/share/GeoIP/GeoLiteCity.dat
else
    echo "The GeoIP library could not be downloaded and updated"
fi

exit 0
