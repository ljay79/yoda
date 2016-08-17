#!/bin/bash

pushd /tmp
wget http://dag.wieers.com/rpm/packages/rssh/rssh-2.3.2-1.2.el5.rf.i386.rpm
rpm -ivh rssh*.rpm
rm -f rssh*.rpm
cat /etc/shells > /tmp/shells
echo '/usr/bin/rssh' >> /tmp/shells
uniq /tmp/shells > /etc/shells
rm -f /tmp/shells
popd

