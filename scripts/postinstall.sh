#!/bin/sh

# set the time correctly
ntpdate -v -b in.pool.ntp.org
date > /etc/vagrant_box_build_time

# update FreeBSD
freebsd-update --not-running-from-cron fetch install

# pkg bootstrap
env ASSUME_ALWAYS_YES=true pkg bootstrap

# upgrade packages
pkg upgrade -y
