#!/bin/bash
# PHP INSTALLER
# NOAH
# This script reads the options file and does a clean/configure/make/install

#set -o errexit
#set -o verbose

source /yoda/bin/inc/init

#test -z $1 && Usage $1 '<what> Ex: php, httpd'

h1 "Preparing to compile PHP with with options from ${BLUE}compile.conf$NC."
mymsg 'Press [ENTER] to continue...'
read 
DEBUG="no"

if [ ! -z $1 ]; then

	if [[ $1 = *debug* ]]; then
		mymsg "Debuging enabled."
		DEBUG="yes"
		shift
	fi
fi

PHP_OPTIONS_FILE="compile.conf"
PHP_OPTIONS=""
PHP_OPTIONS_COUNT=0

PHPTAR=$(find -type f -name 'php-5*.tar.gz' -printf '\n%f' | sort | tail -n1)
PHPVERSION=${PHPTAR%.tar.gz}
PHPVERSION=${PHPVERSION#php-}
sleep 1
mymsg 'Using PHP: ' "$PHPTAR"
mymsg 'Version: ' "$PHPVERSION"
sleep 3
if [ ! -d php ]; then
	mymsg "Untarring PHP..."
	tar -zxf "$PHPTAR"
	RET=$?
	if [ "$RET" != "0" ]; then
		myerror "Where is php?"
		exit 1
	fi
	#find -type d -name "php-*" -exec ln -sf {} php \;
fi

rm -f php
ln -sf "php-${PHPVERSION}" php

if [ ! -f $PHP_OPTIONS_FILE ]
then
	myerror "$PHP_OPTIONS_FILE does not exist"
	exit 1
fi

ENABLED="Enabled:${GREEN} "
WITH=""

for line in `cat $PHP_OPTIONS_FILE | grep '^\s*--'`
do
  if [[ $line = *enable* ]]; then
    ENABLED="$ENABLED ${line##--enable-}"
  fi
  if [[ $line = *with* ]]; then
		WITH="$WITH ${line##--with-}"
  fi
	PHP_OPTIONS="$PHP_OPTIONS $line "
	let "PHP_OPTIONS_COUNT+=1"
done

unset line
sleep 1
mymsg "Number of compile options: $PHP_OPTIONS_COUNT"
sleep 1
mymsg $ENABLED
sleep 2
mymsg "WITH:${GREEN}"
for with in $WITH; do
	echo -e "\t$with"
done
echo -e ${NC};
unset ENABLED WITH with
sleep 2
if [ $DEBUG = "yes" ]; then
	mymsg "Debug build enabled"
	PHP_OPTIONS="$PHP_OPTIONS --enable-debug "
fi

sleep 2

#exec 3<&1 >/dev/null

if [ -d php ]; then pushd php; fi

if [ -d php ]; then pushd php; fi

#exec 1<&3 3>&-

h1 "Cleaning up..."

sleep 2
make clean
make distclean 

h1 "Configuring..."

mymsg $PHP_OPTIONS | more
if [ $# -gt 0 ]; then
	mymsg 'And also...'
	mymsg $*
fi
sleep 1

./configure --help >| ../php-options.txt

sleep 1

./configure $PHP_OPTIONS $*

if [ $? -ne 0 ]; then
	mymsg '***************'
	mymsg 'CONFIGURE ERROR'
	mymsg '***************'
	exit 1
fi

h1 "Making..."
sleep 2
make

if [ $? -ne 0 ]; then
  mymsg '***************'
  mymsg 'MAKE ERROR'
  mymsg '***************'
	exit 1
fi

export MYSQL_TEST_USER="tester"
export MYSQL_TEST_PASSWD="tester"
export MYSQL_TEST_DB="test"
        
h1 "Backing up libphp5.so and /usr/local/bin/php..."
cp -p -v -f /usr/local/apache2/modules/libphp5.so /usr/local/apache2/modules/libphp5.so.bk
cp -p -v -f /usr/local/bin/php /usr/local/bin/php.bk

h1 "Installing...? Yes? 10 seconds to CTRL-C."
sleep 10

if [ $DEBUG = "no" ]; then
	strip sapi/cli/php
	strip .libs/libphp5.so
	strip libs/libphp5.so
fi

APACHECTL=$(which apachectl)
mymsg "Killing php processes and stopping apache..."
$APACHECTL stop
sleep 5
killall php
sleep 1
killall -9 php
sleep 1
$APACHECTL stop
sleep 5
mymsg "Installing PHP"
sleep 1
make install
sleep 1
libtool --finish /yoda/src/php/php/libs
sleep 1
mymsg "Restarting apache"
$APACHECTL restart
sleep 5
$APACHECTL start
sleep 5
$APACHECTL start
popd
popd
mymsg '--------------'
php -v 
mymsg '--------------'

h1 'All DONE!'

exit 0
