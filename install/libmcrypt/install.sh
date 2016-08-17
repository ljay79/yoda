#!/bin/bash

tar -zxvf libmcrypt*
cd libmcrypt*
make clean
./configure --build=${CHOST}
make
make install
cd ..
