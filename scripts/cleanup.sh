#!/bin/sh
set -e

# Disable root logins
sed -i '' -e 's/^PermitRootLogin yes/#PermitRootLogin no/' /etc/ssh/sshd_config

# Purge files we no longer need
rm -rf /boot/kernel.old
# /boot/efi is an MS-DOS mount, allow rm -f to fail (#281033)
rm -f /boot/efi/EFI/FreeBSD/*-old.efi || true
rm -f /boot/efi/EFI/BOOT/*-old.efi || true
rm -f /etc/hostid
rm -f /etc/machine-id
rm -f /etc/ssh/ssh_host_*
rm -f /root/*.iso
rm -f /root/.vbox_version
rm -rf /tmp/*
rm -rf /var/db/freebsd-update/files/*
rm -f /var/db/freebsd-update/*-rollback
rm -rf /var/db/freebsd-update/install.*
rm -f /var/db/pkg/repo-*.sqlite
rm -rf /var/db/pkg/repos/FreeBSD
rm -rf /var/log/*
