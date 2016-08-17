#!/bin/bash

echo "cron $0 works..." >> /yoda/log/cron-10m.log
rm -f /tmp/debug* 

if [ -f /yoda/cron-10m.local.sh ]; then
    /yoda/cron-10m.local.sh >> /yoda/log/cron-10m.log
fi

exit 0
