#!/bin/bash
echo " Cron $0 works..." >> /yoda/log/cron-biweekly.log
if [ -f /yoda/cron-biweekly.local.sh ]; then
    /yoda/cron-biweekly.local.sh >> /yoda/log/cron-biweekly.log
fi