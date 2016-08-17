#!/bin/bash

# For LAMP Installation
# Installs up2date (5.5+) MySQL Client libraries only - NO Server!
#
# Last update: 2014-06-23
# Author: Jens Rosemeier
# Interactive!

YUM=$(which yum)

$YUM install mysql mysql-devel
