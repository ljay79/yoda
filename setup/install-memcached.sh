#!/bin/bash

echo "Going to install memcached..."
sleep 3

NOW=`date +'%s'`

yum -y install libevent
yum -y install libevent-devel

pushd ~
if [ -d memcached ]; then 
	mv memcached "memcache.$NOW"
fi
mkdir memcached
pushd memcached
wget 'http://memcached.googlecode.com/files/memcached-1.4.5.tar.gz'
tar -zxvf memcached-*
cd memcached*
./configure --build=${CHOST} --enable-64bit
make
make install
popd
popd
echo ""
echo "Done."
exit 0
