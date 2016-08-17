#!/bin/bash

set -o errexit

DATE=`date +'%s'`
WHAT="mtstat"
WHERE="install_$WHAT"
URL='http://pypi.python.org/packages/source/m/mtstat/mtstat-0.7.3.tar.gz'

PYTHON=$(which python)

echo "Installing mtstat..."

yum -y install python-setuptools 

pushd ~
if [ -d $WHERE ]; then
	mv $WHERE "$WHERE.${DATE}"
fi
mkdir $WHERE
pushd $WHERE
wget $URL
tar -zxvf *.gz;
rm -f *.gz
cd $WHAT*
PYTHON=`which python`
$PYTHON setup.py install
popd
popd
echo
echo "DONE"
echo


pushd ~
wget 'ftp://ftp.pbone.net/mirror/rpms.famillecollet.com/enterprise/5/remi/x86_64/mysqlclient15-5.0.67-1.el5.remi.x86_64.rpm'
yum -y --nogpgcheck localinstall  mysqlclient15-5.0.67-1.el5.remi.x86_64.rpm
rpm -i --force --nosignature  mysqlclient15-5.0.67-1.el5.remi.x86_64.rpm
ldconfig

yum -y install MySQL-python

WHAT="mtstat-mysql"
WHERE="install_$WHAT"
URL='http://pypi.python.org/packages/source/m/mtstat-mysql/mtstat-mysql-0.7.3.3.tar.gz'

pushd ~
if [ -d $WHERE ]; then
  mv $WHERE "$WHERE.${DATE}"
fi
mkdir $WHERE
pushd $WHERE
wget $URL
tar -zxvf *.gz;
rm -f *.gz
cd $WHAT*
$PYTHON setup.py install
popd
popd
echo
echo "DONE"
echo

