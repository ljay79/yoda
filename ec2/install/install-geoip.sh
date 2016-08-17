#!/bin/bash

# Install GeoIP from source.
# Install GeoIp PHP Module.
# Create cron job for auto update of geoip database with paid license.
#

set -o errexit
#set -o verbose

DATE=`date +'%s'`

pushd ~

if [ -d install_geoip ]; then
    mv install_geoip "install_geoip.${DATE}"
fi

mkdir install_geoip
pushd install_geoip

wget 'http://geolite.maxmind.com/download/geoip/api/c/GeoIP.tar.gz'
tar -zxvf GeoIP.tar.gz
rm -f GeoIP.tar.gz
cd GeoIP*

./configure 
make
make check
make install

popd

wget 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz'
gzip -d GeoLiteCity.dat.gz
if [ ! -d /usr/local/share/GeoIP ]; then
    mkdir /usr/local/share/GeoIP
fi
mv GeoLiteCity.dat* /usr/local/share/GeoIP/GeoIPCity.dat
ln -sf  /usr/local/share/GeoIP  /usr/local/share/GeoIPCity
cp -pf /usr/local/share/GeoIP/GeoIPCity.dat /usr/local/share/GeoIP/GeoLiteCity.dat

popd 

echo
echo "DONE Installing GeoIP on system"
echo

if [ -f /yoda/scripts/install-php-module.sh ]; then
    echo "Now installing PHP Module"
    /yoda/scripts/install-php-module.sh geoip
    echo
    echo "DONE Installing GeoIP PHP Module"
    echo
fi

if [ -f /yoda/scripts/geoip-autoupdate-cron ]; then
    echo "Now setting up a cron job for auto updating GeoIP database"
    cp /yoda/scripts/geoip-autoupdate-cron /etc/cron.d/
fi
if [ -f /yoda/etc/GeoIP.conf ]; then
    mv /usr/local/etc/GeoIP.conf /usr/local/etc/GeoIP.conf.orig
    cp /yoda/etc/GeoIP.conf /usr/local/etc/GeoIP.conf
fi

echo "updating database..."
/usr/local/bin/geoipupdate

echo
echo "#### DONE ####"
echo
