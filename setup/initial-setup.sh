#!/bin/bash

set +v

YUM=$(which yum)

echo "Removing default mysql, apache and php packages..."
echo "And then will install alot of other stuff"
sleep 3

set -v

$YUM -y  groupremove "Mysql*"
$YUM -y groupremove "PHP Support"
$YUM -y groupremove "Web Server"

$YUM -y -q erase mysql*
$YUM -y -q erase httpd*
$YUM -y -q erase php*




sleep 1

$YUM -y groupinstall "Development Libraries"
$YUM -y groupinstall "Development tools"
$YUM -y --skip-broken groupinstall "Additional Development"

######
# redhat 6.2
#####


PACKAGES="sendmail cronie"

for str in $PACKAGES; do
  $YUM -y -q install $str
done


/sbin/chkconfig crond on
/sbin/chkconfig sendmail on

######################

PACKAGES="gd gd-devel libpng libjpeg libpng-devel libjpeg-devel lynx subversion libXpm-devel"


for str in $PACKAGES; do
  $YUM -y -q install $str
done

$YUM -y -q erase mysql* httpd* php*

set +v



