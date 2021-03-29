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
