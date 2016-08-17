#!/bin/bash

echo "Going to install memcached for php..."
sleep 3

NOW=`date +'%s'`

pushd ~
if [ -d memcache_php ]; then 
	mv memcache_php "memcache_php.$NOW"
fi
mkdir memcache_php
pushd memcache_php
wget 'http://pecl.php.net/get/memcache'
tar -zxvf memcache*
cd memcache-*
phpize
./configure --build=${CHOST} --enable-memcache \
--disable-memcache-session --with-php-config=/usr/local/bin/php-config \
--with-gnu-ld --with-libdir=lib64
make
make install
cd /usr/local/lib/php/extensions/no-debug*
cp -vf memcache.so /usr/local/lib/php/extensions
popd
popd
echo ""
echo "Done."
echo "But you still have to set it up in php.ini"
exit 0
