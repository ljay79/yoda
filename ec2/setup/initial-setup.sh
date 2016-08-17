#!/bin/bash

echo "[YODA] Run initial-setup.sh ..."

YUM=$(which yum)

echo "[YODA] Removing default mysql, apache and php packages..."
echo "[YODA] And then will install alot of other stuff"

$YUM -y groupremove "Mysql*"
$YUM -y groupremove "PHP Support"
$YUM -y groupremove "Web Server"

$YUM -y -q erase mysql*
$YUM -y -q erase httpd*
$YUM -y -q erase php*

# Give it some time - otherwise it fails due to "Existing lock /var/run/yum.pid: another copy is running as pid xxx."
sleep 5

$YUM -y -q groupinstall "Development Libraries"
$YUM -y -q groupinstall "Development tools"
#$YUM -y --skip-broken groupinstall "Additional Development"

sleep 5

######
# redhat 6.2
#####

PACKAGES="sendmail cronie"

for str in $PACKAGES; do
  $YUM -y -q install $str
done

/sbin/chkconfig crond on
/sbin/chkconfig sendmail on

sleep 5

######################

PACKAGES="gd gd-devel libpng libjpeg libpng-devel libjpeg-devel lynx subversion libXpm-devel mc"

for str in $PACKAGES; do
  $YUM -y -q install $str
  sleep 2
done

$YUM -y -q erase mysql* httpd* php*

sleep 5

echo "[YODA] initial-setup.sh done ..."
