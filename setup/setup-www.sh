#!/bin/bash

set -v

groupadd -g 500 www
useradd -g 500 -u 500 www

if [ ! -d "/www" ]; then
	mkdir /www
fi

chown www:www /www
chgrp -R www /www
find /www -type d -exec chmod g+s {} \;
chmod 0777 /www
chmod g+s /www
chmod -R g+rwX /www

usermod -d /www www

set +v
