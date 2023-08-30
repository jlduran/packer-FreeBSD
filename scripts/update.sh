#!/bin/sh
set -e

# Set the time
service ntpdate onestart || true

# Update FreeBSD
freebsd-update --not-running-from-cron fetch install || true

# Bootstrap pkg
env ASSUME_ALWAYS_YES=yes pkg bootstrap -f

# Upgrade packages
pkg upgrade -qy

# Upgrade boot partition
fetch -o /tmp https://raw.githubusercontent.com/freebsd/freebsd-src/main/tools/boot/install-boot.sh
sh /tmp/install-boot.sh
