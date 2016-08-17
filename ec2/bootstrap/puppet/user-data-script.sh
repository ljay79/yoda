#!/bin/sh
# sample script
set -e -x

yum --assumeyes --quiet update
yum --assumeyes --quiet install git puppet3

# Fetch puppet configuration from public git repository.
mv /etc/puppet /etc/puppet.orig
git clone https://github.com/ljay79/ec2-puppet-boot.git /etc/puppet

# Run puppet.
puppet apply /etc/puppet/manifests/init.pp
