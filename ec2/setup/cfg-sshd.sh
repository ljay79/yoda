#!/bin/bash

echo "[YODA] Run cfg-sshd.sh ..."

SSH_CFG_FILE="/yoda/ec2/etc/ssh_config"
SSHD_CFG_FILE="/yoda/ec2/etc/sshd_config"

if [ -f $SSHD_CFG_FILE ]; then
    echo "[YODA] Override sshd config"
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
    cp /etc/ssh/ssh_config /etc/ssh/ssh_config.orig
    #
    cp $SSH_CFG_FILE /etc/ssh/ssh_config
    cp $SSHD_CFG_FILE /etc/ssh/sshd_config
    chown root:root /etc/ssh/ssh_config
    chmod 644 /etc/ssh/ssh_config
    chown root:root /etc/ssh/sshd_config
    chmod 644 /etc/ssh/sshd_config
fi

/sbin/service sshd restart
