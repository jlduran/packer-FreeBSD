#!/bin/sh -e

# Disable root logins
sed -i '' -e 's/^PermitRootLogin yes/#PermitRootLogin no/' /etc/ssh/sshd_config

# Purge files we no longer need
rm -f /root/*.iso
rm -f /root/.vbox_version
rm -rf /tmp/*
rm -rf /var/db/freebsd-update/files/*
rm -f /var/db/freebsd-update/*-rollback
rm -rf /var/db/freebsd-update/install.*
rm -f /var/db/pkg/repo-*.sqlite
rm -rf /boot/kernel.old
rm -f /etc/ssh/ssh_host_*
