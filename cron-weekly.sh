#!/bin/bash

echo " Cron $0 works..." >> /yoda/log/cron-weekly.log
if [ -f /yoda/cron-weekly.local.sh ]; then
    /yoda/cron-weekly.local.sh >> /yoda/log/cron-weekly.log
fi
