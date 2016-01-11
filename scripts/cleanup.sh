#!/bin/sh

# purge files we no longer need
rm -f /home/vagrant/*.iso
rm -f /home/vagrant/.vbox_version
rm -rf /tmp/*
rm -rf /var/db/freebsd-update/files/*
rm -f /var/db/freebsd-update/*-rollback
rm -rf /var/db/freebsd-update/install.*
rm -rf /boot/kernel.old
