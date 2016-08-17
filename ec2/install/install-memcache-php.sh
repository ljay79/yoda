#!/bin/bash

# For LAMP Installation
# Install memcache pecl php module from YUM - only when php installation through YUM as well.
# Otherwise use /yoda/setup/install-memcache-php.sh to compile a nice one.
#
# Last update: 2014-06-26
# Author: Jens Rosemeier
# Interactive!

echo "[YODA] Installing php module 'memcache'..."

YUM=$(which yum)

$YUM install php-pecl-memcache

echo "... reloading apache"
service httpd restart

echo 
echo "If correct installed, you should see some memcache conf in the php.ini .."
php -i | grep memcach
