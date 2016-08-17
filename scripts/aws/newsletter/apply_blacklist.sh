#!/bin/bash

DBNAME="newsletter"
DBUSER="aws*****RW"
DBPASS="***********"
DBHOST="db2.*********.rds.amazonaws.com"

DATE=`date +%Y%m%d-%H%M`

# first dump blacklist
mysql -u$DBUSER -p"$DBPASS" -h $DBHOST --database=$DBNAME -e "SELECT bl.\`email\` FROM \`bb_newsletter_blacklist\` AS bl INNER JOIN \`nl_subscriptions\` AS nl USING(\`email\`) WHERE nl.\`status\` = 1;" | while read blacklisted_email; do
    # echo "email to disable: $blacklisted_email"
    mysql -u$DBUSER -p"$DBPASS" -h $DBHOST --database=$DBNAME -e "UPDATE \`nl_subscriptions\` SET status = 0 WHERE email LIKE '%$blacklisted_email%';"
done

