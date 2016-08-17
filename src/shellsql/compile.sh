#!/bin/bash
# compile.sh

source /yoda/bin/inc/init

cd shellsql-*

mymsg Going to install shellsql

make clean
cd src
rm -f *.o
find -type f -perm /u+x -exec rm -v -f /usr/bin/{} \;
find -type f -perm /u+x -exec rm -v -f {} \;
cd ..
./install.sh mysql
make install

cd ..

mysuccess Done, its in /usr/bin.


exit 0
