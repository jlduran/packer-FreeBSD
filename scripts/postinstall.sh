#!/bin/sh

# set the time correctly
ntpdate -v -b in.pool.ntp.org

date > /etc/vagrant_box_build_time

# disable X11
echo 'WITHOUT_X11="YES"' >> /etc/make.conf

# allow freebsd-update to run fetch without stdin attached to a terminal
# NOTE: after the update, freebsd-update will support `--not-running-from-cron`
# to avoid this hack
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/freebsd-update > /tmp/freebsd-update
chmod +x /tmp/freebsd-update

# update FreeBSD
env PAGER=/bin/cat /tmp/freebsd-update fetch
env PAGER=/bin/cat /tmp/freebsd-update install

# install ports collection
portsnap --interactive fetch
portsnap extract

# pkg bootstrap
env ASSUME_ALWAYS_YES=true pkg bootstrap

# upgrade packages
pkg upgrade -y
