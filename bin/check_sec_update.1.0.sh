#!/bin/bash
#
# Name:         check_sec_update
# Author:       Yves Serge Joseph
# Function:     Run from cron to check for yum security updates.
#               +mail result to admin account
# Version:      1.0
# Config:       ~sjoseph/app
# Date:         November 26th, 2012

set +f

# send email
MAIL_USER=${MAILTO:=sysadmin@example.com}
yum_data_file="/tmp/yum-check-update.$$"
yum_base="/usr/bin/yum"
output_data_file="/tmp/output_data_file.$$"

# clean up if the files exist
[ -e "${yum_data_file%%[0-9]*}*" ] && rm -f ${yum_data_file%%[0-9]*}*
[ -e "${output_data_file%%[0-9]*}*" ] && rm -f ${output_data_file%%[0-9]*}*
[ -e "${yum-check-update%%[0-9]*}*" ] && rm -f ${yum-check-update%%[0-9]*}*
# check for security updates, and if any, do the the install
### $yum_base -e0 -d0 check-update --security  > $yum_data_file
$yum_base check-update --security  > $yum_data_file

yum_state="$?"
echo "yum_state: $yum_state"

case $yum_state in
         100)

             # Check that the list of update exist 
             if [[ -e $yum_data_file ]]; then
	     echo -e " The following security updates are available for host  ${HOSTNAME}:\n " | cat -  $yum_data_file >/tmp/out && mv -f /tmp/out $yum_data_file

	     #  install any updates that may have been found; if successful  and  send report
             ## uncomment the lines with three pound signs below to perform securty update
             ### yum update --security -y > $output_data_file
             ### if [[ $?=0 ]]; then
                  
             ### echo -e " \n\n\n Security updates successfully ran on $HOSTNAME \n" | cat - $output_data_file >/tmp/out && mv -f /tmp/out $output_data_file

	     # Combine available security updates report with installed updates and email report

	     ### cat  $output_data_file >>$yum_data_file
	     cat  $yum_data_file | mail -s " Yum Security Update report for ${HOSTNAME} " $MAIL_USER
	     cat  $yum_data_file | mail -s " Yum Security Update report for ${HOSTNAME} " sysadmin@example.com
             
             ###     fi
                             fi

             # clean up the files in tmp directory

	       [ -e "${yum_data_file}" ] && rm -f ${yum_data_file}
	       [ -e "${output_data_file}" ] && rm -f ${output_data_file}
                  ;;
         0)
               # Only send mail if datafile exist
               if [ -e $yum_data_file ]; then
               echo "  " >>$yum_data_file
               echo " No Yum Security Updates are available for Host ${HOSTNAME}. " |cat -  $yum_data_file>/tmp/output && mv -f /tmp/output $yum_data_file
                  
               cat $yum_data_file | mail  -s " No Yum Security Updates are available for ${HOSTNAME}." $MAIL_USER
                       fi
                  ;;
         *)
                 # Unexpected yum return status
                 (echo "Undefined, yum return status: ${yum_state}" && \
                 [ -e "${yum_data_file}" ] && cat "${yum_data_file}" )|\
                 mail  -s "unable to run  Yum Security Updates on  ${HOSTNAME} . Please, verify  your source code" $MAIL_USER
esac

[ -e "${yum_data_file}" ] && rm -f ${yum_data_file}
