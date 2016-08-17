#!/bin/bash

PHPMOD="runkit"
EXTPARMS=""

PHPIZE=$(which phpize)
PHPCONFIG=$(which php-config)
PHPEXTDIR=$(${PHPCONFIG} --extension-dir)
WGET=$(which wget)
PHP=$(which php);
PHPINI=$($PHP --ini | head -n1 | awk -F ': ' '{print $2}')
PHPINI="${PHPINI}/php.ini"

if [ ! -f $PHPINI ]; then
	 echo "php.ini?"
	exit 1
fi

if [ ! -f $PHPCONFIG ]; then
	echo "where is php-config"
	exit 1
fi

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
$PHPIZE
./configure --build=${CHOST} --with-php-config=${PHPCONFIG} --with-gnu-ld --with-libdir=lib64 $EXT_PARMS

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
if [ ! -d $PHPEXTDIR ]; then
	echo "where is extension dir"
	exit 1
fi
cd $PHPEXTDIR
cp -vfp *.so ../
popd
popd
echo ""
echo "Done."
echo "But you still have to set it up in php.ini with:"
echo 'extension=${PHPMOD}.so
exit 0
