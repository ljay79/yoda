#!/bin/bash

echo " Cron $0 works..." >> /yoda/log/cron-hourly.log
if [ -f /yoda/cron-hourly.local.sh ]; then
    /yoda/cron-hourly.local.sh >> /yoda/log/cron-hourly.log
fi
