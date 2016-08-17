#!/bin/bash

source /yoda/bin/inc/init

if [ -z $1 ]; then
	mymsg "Install any PECL module in 2 seconds off the PECL site."
	mymsg "This is for PECL modules only that are not included in normal PHP src."
	mymsg 'Note: You must spell the module name exactly right as it is in the URL on the PECL site.'
	mymsg "Usage: $0 " '<module name>';
	mymsg "Ex: ./install-php-module.sh geoip"
	mymsg "Ex: ./install-php-module.sh geoip --special-parms --with-mysql=/usr"
	echo
	exit 1
fi

PHPMOD="$1"
PHPMOD_LOWER=$(echo $PHPMOD | awk '{print tolower($0)}')
PHPMOD_UPPER=$(echo $PHPMOD | awk '{print toupper($0)}')
EXTPARMS=""

PHPIZE=$(which phpize)
PHPCONFIG=$(which php-config)
PHPEXTDIR=$(${PHPCONFIG} --extension-dir)
WGET=$(which wget)
PHP=$(which php);
PHPINI=$($PHP --ini | head -n1 | awk -F ': ' '{print $2}')
PHPINI="${PHPINI}/php.ini"

sleep 0.5

PHPMOD_URL="http://pecl.php.net/get/$PHPMOD"

#if [[ "$2" ]]; then
#	PHPMOD_URL="$2"
#fi

shift 
EXTPARAMS="$*"

if [ ! -f $PHPINI ]; then
	 myerror "php.ini?"
	exit 1
fi

if [ ! -f $PHPCONFIG ]; then
	myerror  "where is php-config"
	exit 1
fi

if [ ! -f $WGET ]; then
  myerror "where is wget"
  exit 1
fi

echo
echo -e "${YELLOW}Going to install ${CYAN}$PHPMOD ${YELLOW} for php...${NC}"
sleep 3

NOW=`date +'%s'`

pushd ~
if [ -d "${PHPMOD}_php" ]; then 
	mv ${PHPMOD}_php "${PHPMOD}_php.$NOW"
fi
mkdir ${PHPMOD}_php
pushd ${PHPMOD}_php
MODFILE="${PHPMOD}.tar.gz"

mymsg "Downloading from $PHPMOD_URL . . ."
sleep 2

echo -e "${WHITE}Downloading $CYAN $MODFILE. . .${NC}"
#echo "$WGET -q -O $MODFILE '$PHPMOD_URL'"

$WGET --no-check-certificate -q -O $MODFILE "$PHPMOD_URL"

if [ $? -ne 0 ]; then
	myerror "Unable to download $PHPMOD."
	myerror 'Maybe not a valid module name? Check the PECL site.'
	echo
	mymsg 'Suggestions if any:'
	lynx -dump 'http://pecl.php.net/package-search.php?pkg_name='${PHPMOD}'&bool=AND' | grep -P '^\s*\[\d\d\]\w'
	echo
	exit 1
fi
if [ ! -f $MODFILE ]; then
	myerror "Unable to download $PHPMOD."
	exit 1
fi

echo
echo -e "${WHITE}Uncompressing...$NC"
echo

sleep 2

tar -zxf $MODFILE
rm -fv $MODFILE
pushd $PHPMOD-*
if [ $? -gt 0 ]; then
	pushd $PHPMOD_LOWER-*
fi
if [ $? -gt 0 ]; then
	pushd *$PHPMOD*
fi
if [ $? -gt 0 ]; then
    pushd *$PHPMOD_UPPER*
fi
echo
echo -e "${WHITE}Running phpize. . .$blue"
echo
sleep 2
$PHPIZE
sleep 2
echo
echo -e "${WHITE}Configuring . . .$blue"
echo
sleep 2

./configure --build=${CHOST} --with-php-config=${PHPCONFIG} --with-gnu-ld --with-libdir=lib64 $EXTPARMS

if [ $? -ne 0 ]; then
	myerror "Configure failed"
	exit 1
fi
echo
echo -e "${WHITE}Compiling . . .$blue"
echo 
sleep 1
make
if [ $? -ne 0 ]; then 
	myerror "There was a problem compiling. Might require custom params."
	exit 1
fi
echo
echo -e "${WHITE}Installing. . .$blue"
echo
sleep 1
make install
echo
if [ ! -d $PHPEXTDIR ]; then
	echo 'where is extension dir?'
	exit 1
fi
popd
cd $PHPEXTDIR
cp -vfp *.so ../
popd
popd
echo ""
mysuccess "Done."
echo

LOADED=$(cat $PHPINI | grep -i -c  "${PHPMOD}.so")

if [ "$LOADED" = "0" ]; then 
	chattr -i $PHPINI
	echo "" >> $PHPINI
	echo "extension=${PHPMOD}.so" >> $PHPINI
	chattr +i $PHPINI
	echo -e "${WHITE}The extension has also been added to ${GREEN}php.ini${NC}."
	echo

else
	echo -e "${WHITE}It appears the extension is already loaded in your php.ini.${NC}"
fi

mysuccess "Bye."


exit 0
