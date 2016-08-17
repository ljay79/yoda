#!/bin/bash

# For LAMP Installation (includes libs to compile software yourself)
# Should be ran *before* continuing with installing apache, mysql or php, ...
# Installs only few compiler libs, gcc, libxml, etc.
#
# Last update: 2014-06-23
# Author: Jens Rosemeier
# Interactive!

YUM=$(which yum)

$YUM install gcc make libtool gcc-c++ pcre pcre-devel zlib-devel
$YUM install libxml2 libxml2-devel
$YUM install mlocate

updatedb

# For apache and others
$YUM install apr-devel
