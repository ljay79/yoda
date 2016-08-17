#!/bin/bash

# Install and compile Apache2
# Run this script from this directory!
#
# Author: Noah Ellman, Jens Rosemeier
# Last update: 2014-06-23

#set -o errexit
#set -o verbose

# change to version you want to install
# set to latest 2.4 ersion = 2.4.9
APACHE_URL='http://www.webhostingjams.com/mirror/apache//httpd/httpd-2.4.9.tar.gz'
APR_URL='http://apache.mirror.quintex.com//apr/apr-1.5.1.tar.gz'
APRUTIL_URL='http://apache.mirror.quintex.com//apr/apr-util-1.5.3.tar.gz'

##################################################


if [ "x$1" != "x" ]; then
    APACHE_URL=$1
    shift
fi

source /yoda/bin/inc/init

set +f

mymsg "Using $APACHE_URL"

if [ "x$1" = "xdebug" ]; then
	DEBUG="yes"
	mymsg "(debug mode)"
	shift
else
	DEBUG="no"
fi

if [ -d /usr/local/apache2/conf ]; then
    mymsg "Backing up httpd conf folder..."
    cp -rf /usr/local/apache2/conf /backup/apache_conf_folder
fi

mymsg "Downloading HTTPD. . ."
wget -q "$APACHE_URL" -O - > httpd.tar.gz
if [ "$?" != "0" -o ! -f httpd.tar.gz ]; then
	myerror "Problem downloading apache."
	exit 1
fi

mymsg "Downloading APR. . ."
wget -q "$APR_URL" -O - > apr.tar.gz
if [ "$?" != "0" -o ! -f apr.tar.gz ]; then
	myerror "Problem downloading apr."
	exit 1
fi

mymsg "Downloading APR Util. . ."
wget -q "$APRUTIL_URL" -O - > apr-util.tar.gz
if [ "$?" != "0" -o ! -f apr-util.tar.gz ]; then
	myerror "Problem downloading apr-util."
	exit 1
fi


mymsg "Uncompressing.."
tar -zxf httpd.tar.gz
rm -f httpd.tar.gz
find -type d -name "httpd-2*" -exec ln -sf {} httpd \;

mymsg "Uncompressing.."
tar -zxf apr.tar.gz
rm -f apr.tar.gz
#find $PWD -type d -name "apr-1*" -exec ln -sf {} httpd/srclib/apr \;
APRPATH=$(find $PWD -type d -name "apr-1*")
mv $APRPATH httpd/srclib/apr

mymsg "Uncompressing.."
tar -zxf apr-util.tar.gz
rm -f apr-util.tar.gz
#find $PWD -type d -name "apr-util-1*" -exec ln -sf {} httpd/srclib/apr-util \;
APRUPATH=$(find $PWD -type d -name "apr-util-1*")
mv $APRUPATH httpd/srclib/apr-util

OPTIONS_FILE="compile.conf"
OPTIONS=""
OPTIONS_COUNT=0
SPACE=" "


if [ ! -f $OPTIONS_FILE ]
then
	myerror  "$OPTIONS_FILE does not exist"
	exit 1
fi

cp -fp $OPTIONS_FILE httpd/config.nice

if [ -d httpd ]; then pushd httpd; fi

./configure --help >| ../options.txt

echo -e "${YELLOW}--------------------------------------------------------------------"
echo
mymsg "Cleaning up. . ."
sleep 2
echo -e "${blue}"
make clean
make distclean 

echo
echo -e "${GREEN}--------------------------------------------------------------------"
mymsg "Configuring. . ."

sleep 2
chmod +x config.nice
if [ "$DEBUG" = "yes" ]; then
	mymsg "Compiling in debug mode."
	echo -e "${blue}"
	./config.nice --enable-maintainer-mode
else
	echo -e "${blue}"
	./config.nice
fi

RET=$?

echo -e "${NC}"

if [ $RET -ne 0 ]; then
	echo '***************'
	myerror 'CONFIGURE ERROR'
	echo '***************'
	exit 1
fi

echo
echo -e "${YELLOW}--------------------------------------------------------------------"
mymsg "Making..."
echo
sleep 2
echo -e "${blue}"
make
RET=$?
echo -e "${NC}"
if [ $RET -ne 0 ]; then
  echo '***************'
  myerror 'MAKE ERROR'
  echo '***************'
	exit 1
fi
        
echo

setuplinks () {
    ln -fs /usr/local/apache2/bin/htdbm /usr/bin/htdbm
    ln -fs /usr/local/apache2/bin/apxs /usr/sbin/apxs
    ln -fs /usr/local/apache2/bin/ab /usr/bin/ab
    ln -fs /usr/local/apache2/bin/apu-1-config /usr/bin/apu-1-config
    ln -fs /usr/local/apache2/bin/apr-1-config /usr/bin/apr-1-config
    ln -fs /usr/local/apache2/bin/apachectl /usr/sbin/apachectl
    ln -fs /usr/local/apache2/bin/apachectl /usr/sbin/httpd
    ln -fs /usr/local/apache2/bin/httpd /usr/sbin/httpd.worker

    if [ ! -f /sbin/apachectl ]; then
	ln -fs /usr/local/apache2/bin/apachectl /sbin/apachectl
    fi

    if [ -d /etc/httpd ]; then
	if [ -L /etc/httpd ]; then
		ln -fs /usr/local/apache2/conf /etc/httpd
	else
		if [ -d /etc/httpd.old ]; then
			rm -fv /etc/httpd.old.old
			mv /etc/httpd.old /etc/httpd.old.old
		fi
		mv /etc/httpd /etc/httpd.old
		ln -fs /usr/local/apache2/conf /etc/httpd
	fi
    else 
	ln -sf /usr/local/apache2/conf /etc/httpd
    fi
}

setuplinks

echo -e "${YELLOW}--------------------------------------------------------------------"
mymsg "Ready to install."
mymsg "Note: Apache will be restarted during this process"
mymsg "Press any key or CTRL-C to install later..."
read
sleep 2
echo
echo

mymsg "Stopping apache...";

APACHECTL="/sbin/apachectl"

if [ ! -f "$APACHECTL" ]; then
	APACHECTL="/bin/echo"
fi
$APACHECTL stop
sleep 5
killall php
sleep 2
killall -9 php
sleep 2
$APACHECTL stop
sleep 2

mymsg "Installing new apache..."
sleep 1
echo

make install

if [ ! -f /sbin/apachectl ]; then
  ln -fs /usr/local/apache2/bin/apachectl /sbin/apachectl
fi

setuplinks

ldconfig

APACHECTL="/sbin/apachectl"

mymsg "Restarting apache..."
sleep 5

$APACHECTL restart
sleep 5
$APACHECTL start
sleep 5
/sbin/apachectl start
sleep 1

popd
popd

echo
echo
mysuccess "ALL DONE."
echo

exit 0
