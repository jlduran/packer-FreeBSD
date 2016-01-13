#!/bin/sh

# Install avahi-app
pkg install -y net/avahi-app

# Enable avahi-daemon
echo 'dbus_enable="YES"' > /etc/rc.conf.d/dbus
echo 'avahi_daemon_enable="YES"' > /etc/rc.conf.d/avahi_daemon
