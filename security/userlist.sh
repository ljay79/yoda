#!/bin/bash
# userlist.sh
# not clear what the purpose of this is :/

source /yoda/bin/inc/init

USERS=$(cat /etc/passwd | grep -P '/home|/www' | awk -F':' '{print $1 }' | sort )

for u in $USERS; do
  if [ ${#u} -gt 3 ]; then
        /yoda/bin/usercopy -2 $u
  fi
done

unset u

exit 0
