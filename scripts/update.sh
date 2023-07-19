#!/bin/sh
set -e

# XXX test
sysrc ntpdate_hosts="ntp.ubuntu.com"
# XXX test

# Set the time
service ntpdate onestart || true

# XXX test
sysrc ntpdate_hosts=""
# XXX test

# Update FreeBSD
freebsd-update --not-running-from-cron fetch install || true

# Bootstrap pkg
env ASSUME_ALWAYS_YES=yes pkg bootstrap -f

# Upgrade packages
pkg upgrade -qy
