#!/bin/bash
# PHP INSTALLER
# NOAH
# This script reads the options file and does a clean/configure/make/install

set -o errexit
#set -o verbose

source /yoda/bin/inc/init

test -z $1 && Usage '<what> Ex: php, httpd'

SRC="$1"

h1 "Preparing to compile $SRC with with options from ${BLUE}compile.conf$NC."
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

	

OPTIONS_FILE="compile.conf"
OPTIONS=""
OPTIONS_COUNT=0




if [ ! -d $SRC ]; then
	mymsg "Untarring PHP..."
	tar -zxf $SRC*.tar.gz
	RET=$?
	if [ "$RET" != "0" ]; then
		myerror "Where is $SRC?"
		exit 1
	fi
fi

find -type d -name "$SRC-*" -exec ln -sf {} $SRC \;

if [ ! -f $OPTIONS_FILE ]
then
	myerror "$OPTIONS_FILE does not exist"
	exit 1
fi

ENABLED="Enabled:${GREEN} "
WITH=""

for line in `cat $OPTIONS_FILE | grep '^\s*--'`
do
  if [[ $line = *enable* ]]; then
    ENABLED="$ENABLED ${line##--enable-}"
  elif [[ $line = *with* ]]; then
		WITH="$WITH ${line##--with-}"
 	else 
		OTHER="$line"
	fi
	OPTIONS="$OPTIONS $line "
	let "OPTIONS_COUNT+=1"
done

unset line
sleep 1
mymsg "Number of compile options: $OPTIONS_COUNT"
sleep 1
mymsg $ENABLED
sleep 2
mymsg "WITH:${GREEN}"
for with in $WITH; do
	echo -e "\t$with"
done
mymsg "AND:${GREEN} ${OTHER}"
echo -e ${NC};
unset ENABLED WITH with
sleep 2
if [ $DEBUG = "yes" ]; then
	mymsg "Debug build enabled"
	OPTIONS="$OPTIONS --enable-debug "
fi

sleep 2

if [ -d $SRC ]; then pushd $SRC; fi

if [ -d $SRC ]; then pushd $SRC; fi

h1 "Cleaning up..."

sleep 2
make clean
make distclean 

h1 "Configuring..."

mymsg $OPTIONS | more
if [ $# -gt 0 ]; then
	mymsg 'And also...'
	mymsg $*
fi
sleep 2

./configure $OPTIONS $*

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
        


h1 "Installing...? Yes? 10 seconds to CTRL-C."
sleep 10

make install
sleep 2
popd 
popd

mysuccess "DONE."

exit 0
