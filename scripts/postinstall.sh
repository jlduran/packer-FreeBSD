#!/bin/sh

# set the time correctly
ntpdate -v -b in.pool.ntp.org

date > /etc/vagrant_box_build_time

# disable X11
echo 'WITHOUT_X11="YES"' >> /etc/make.conf

# update FreeBSD
freebsd-update --not-running-from-cron fetch install

# install ports collection
portsnap --interactive fetch
portsnap extract

# pkg bootstrap
env ASSUME_ALWAYS_YES=true pkg bootstrap

# upgrade packages
pkg upgrade -y
