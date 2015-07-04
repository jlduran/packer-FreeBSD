#!/bin/sh

# install avahi-app
pkg install -y net/avahi-app

# enable avahi-daemon
echo 'dbus_enable="YES"' > /etc/rc.conf.d/dbus
echo 'avahi_daemon_enable="YES"' > /etc/rc.conf.d/avahi_daemon
