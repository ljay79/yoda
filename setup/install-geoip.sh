#!/bin/bash

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
echo "DONE"
echo

