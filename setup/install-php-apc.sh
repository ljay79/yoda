#!/bin/bash

PHPMOD="APC"

echo "Going to install $PHPMOD for php..."
sleep 3

NOW=`date +'%s'`

pushd ~
if [ -d "${PHPMOD}_php" ]; then 
	mv ${PHPMOD}_php "${PHPMOD}_php.$NOW"
fi
mkdir ${PHPMOD}_php
pushd ${PHPMOD}_php
wget "http://pecl.php.net/get/$PHPMOD"
if [ $? -ne 0 ]; then
	echo "error"
	exit 1
fi
tar -zxvf $PHPMOD*
cd $PHPMOD-*
/usr/local/bin/phpize
./configure --build=${CHOST} --enable-apc \
--enable-apc-filehits \
--with-php-config=/usr/local/bin/php-config --with-gnu-ld --with-libdir=lib64
if [ $? -ne 0 ]; then
	echo "Configure failed"
	exit 1
fi
make
if [ $? -ne 0 ]; then 
	echo "There was a problem."
	exit 1
fi
make install
cd /usr/local/lib/php/extensions/no-debug*
cp -vf *.so /usr/local/lib/php/extensions
popd
popd
echo ""
echo "Done."
echo "But you still have to set it up in php.ini."
exit 0
