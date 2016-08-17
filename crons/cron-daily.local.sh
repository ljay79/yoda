#!/bin/bash
# Put daily cron tasks here that are ONLY for this local machine

#echo " Cron $0 works..." >> /yoda/log/cron-daily.log

/yoda/scripts/update_hostips.sh
