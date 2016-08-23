#!/bin/sh -e

RC_CONF_DIR=/usr/local/etc/rc.conf.d

# Install avahi-app
pkg install -y avahi-app

# Enable avahi-daemon
mkdir -p "$RC_CONF_DIR"
sysrc -f "$RC_CONF_DIR"/dbus dbus_enable=YES
sysrc -f "$RC_CONF_DIR"/avahi_daemon avahi_daemon_enable=YES
