#!/bin/bash

# create a /backup and /trash directory of not present

echo "[YODA] Run backup-dir.sh ..."

if [ ! -d /backup ]; then
	mkdir /backup
fi
chown -R root:wheel /backup
chmod +t /backup
chmod -R ug+wX /backup
chmod -R o-rx /backup
chmod -R o+w /backup

if [ ! -d /trash ]; then
	mkdir /trash
fi
chown -R root:wheel /trash
chmod +t /trash
chmod -R ug+wX /trash
chmod -R o-rx /trash
chmod -R o+w /trash
