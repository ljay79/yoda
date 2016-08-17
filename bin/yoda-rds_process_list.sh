#!/bin/bash

hosts=(db1 db2 db3 db4 db5 db6 db7)

for host in ${hosts[@]}; do
echo "== $host =="|logger -s -t yoda-rds
mysqladmin -u loguser  -h $host processlist|while read i
   do
         echo $i|logger -s -t yoda-rds
   done
done

