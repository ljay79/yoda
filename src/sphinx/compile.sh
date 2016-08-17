#!/bin/bash
# SPHINX INSTALLER
# NOAH
# This script reads the options file and does a clean/configure/make/install

#set -o errexit
#set -o verbose

source /yoda/bin/inc/init

#test -z $1 && Usage $1 '<what> Ex: sphinx, httpd'

h1 "Preparing to compile SPHINX with with options from ${BLUE}compile.conf$NC."
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

SPHINX_OPTIONS_FILE="compile.conf"
SPHINX_OPTIONS=""
SPHINX_OPTIONS_COUNT=0

SPHINXTAR=$(find -type f -name 'sphinx-*.tar.gz' -printf '\n%f' | sort | tail -n1)
SPHINXVERSION=${SPHINXTAR%.tar.gz}
SPHINXVERSION=${SPHINXVERSION#sphinx-}
sleep 1
mymsg 'Using SPHINX: ' "$SPHINXTAR"
mymsg 'Version: ' "$SPHINXVERSION"
sleep 3
if [ ! -d sphinx ]; then
	mymsg "Untarring SPHINX..."
	tar -zxf "$SPHINXTAR"
	RET=$?
	if [ "$RET" != "0" ]; then
		myerror "Where is sphinx?"
		exit 1
	fi
	#find -type d -name "sphinx-*" -exec ln -sf {} sphinx \;
fi

rm -f sphinx
ln -sf "sphinx-${SPHINXVERSION}" sphinx

if [ ! -f $SPHINX_OPTIONS_FILE ]
then
	myerror "$SPHINX_OPTIONS_FILE does not exist"
	exit 1
fi

ENABLED="Enabled:${GREEN} "
WITH=""

for line in `cat $SPHINX_OPTIONS_FILE | grep '^\s*--'`
do
  if [[ $line = *enable* ]]; then
    ENABLED="$ENABLED ${line##--enable-}"
  fi
  if [[ $line = *with* ]]; then
		WITH="$WITH ${line##--with-}"
  fi
	SPHINX_OPTIONS="$SPHINX_OPTIONS $line "
	let "SPHINX_OPTIONS_COUNT+=1"
done

unset line
sleep 1
mymsg "Number of compile options: $SPHINX_OPTIONS_COUNT"
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
	SPHINX_OPTIONS="$SPHINX_OPTIONS --enable-debug "
fi

sleep 2

#exec 3<&1 >/dev/null

if [ -d sphinx ]; then pushd sphinx; fi

if [ -d sphinx ]; then pushd sphinx; fi

#exec 1<&3 3>&-

h1 "Cleaning up..."

sleep 2
make clean
make distclean 

h1 "Configuring..."

mymsg $SPHINX_OPTIONS | more
if [ $# -gt 0 ]; then
	mymsg 'And also...'
	mymsg $*
fi
sleep 2

./configure $SPHINX_OPTIONS $*

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

h1 "Installing...? Yes? 10 seconds to CTRL-C."
sleep 10

mymsg "Installing SPHINX"
sleep 1
make install
sleep 1
popd
popd
mymsg '--------------'

h1 'All DONE!'

exit 0
