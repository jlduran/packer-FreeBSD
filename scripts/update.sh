#!/bin/sh -e

# Set the time
service ntpdate onestart

# Update FreeBSD
freebsd-update --not-running-from-cron fetch install || true

# Bootstrap pkg
env ASSUME_ALWAYS_YES=yes pkg bootstrap -yf

# Upgrade packages
pkg upgrade -y
