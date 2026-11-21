#!/bin/sh
set -e

# Set the time
service ntpd onefetch || true
timeout 5 ntpd -gq || true

# Update FreeBSD
pkg upgrade -qy

# Upgrade boot partition
fetch -o /tmp https://raw.githubusercontent.com/freebsd/freebsd-src/main/tools/boot/install-boot.sh
sh /tmp/install-boot.sh
