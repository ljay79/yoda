#!/bin/bash
# INSTALLER
# NOAH
# This script reads the options file and does a clean/configure/make/install

#set -o errexit
#set -o verbose

source /yoda/bin/inc/init

PWD=`pwd`
PACKAGE=`basename $PWD`

h1 "Preparing to install $YELLOW $PACKAGE"
sleep 1

if [ ! -z $1 ]; then

	if [[ $1 = *debug* ]]; then
		mymsg "Debuging enabled."
		DEBUG="yes"
		shift
	fi
fi

if [ -z $DEBUG ]; then DEBUG="no"; fi
	

OPTIONS_FILE=${1-"compile.conf"}
OPTIONS=""
OPTIONS_COUNT=0




if [ ! -d $PACKAGE ]; then
	mymsg "Untarring $PACKAGE..."
	if [[ -f $PACKAGE.tar.gz ]]; then
		tar -zxf $PACKAGE.tar.gz
		RET=$?
	else
		RET=1
	fi
	if [ "$RET" != "0" ]; then
		myerror "Where is the $PACKAGE tar.gz?"
		echo -n "Enter the URL: "
		read URL
		wget -q "$URL" -O - > $PACKAGE.tar.gz		
		RET=$?
		myerror "Download failed"
		tar -zxf $PACKAGE.tar.gz
	fi
	find -type d -name "$PACKAGE-*" -exec ln -sf {} $PACKAGE \;
fi

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
  fi
  if [[ $line = *with* ]]; then
		WITH="$WITH ${line##--with-}"
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
echo -e ${NC};
unset ENABLED WITH with
sleep 2
if [ $DEBUG = "yes" ]; then
	mymsg "Debug build enabled"
	OPTIONS="$OPTIONS --enable-debug "
fi

sleep 2

pushd $PACKAGE

h1 "Cleaning up the src..."

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

checkfail $? 'CONFIGURE'

h1 "Making..."
sleep 2
make

checkfail $? 'MAKING' 

h1 "Installing...? Yes? 10 seconds to CTRL-C."
sleep 10

mysuccess "DONE."

exit 0
