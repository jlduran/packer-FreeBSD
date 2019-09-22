#!/bin/sh -e

if [ -e /tmp/rc-local ]; then
	MDNSD_RC_CONF_FILE=/etc/rc.conf.local
	MDNSRESPONDERPOSIX_RC_CONF_FILE=/etc/rc.conf.local
elif [ -e /tmp/rc-vendor ]; then
	MDNSD_RC_CONF_FILE=/etc/defaults/vendor.conf
	MDNSRESPONDERPOSIX_RC_CONF_FILE=/etc/defaults/vendor.conf
elif [ -e /tmp/rc-name ]; then
	MDNSD_RC_CONF_FILE=/usr/local/etc/rc.conf.d/mdnsd
	MDNSRESPONDERPOSIX_RC_CONF_FILE=/usr/local/etc/rc.conf.d/mdnsresponderposix
	mkdir -p /usr/local/etc/rc.conf.d
else
	MDNSD_RC_CONF_FILE=/etc/rc.conf
	MDNSRESPONDERPOSIX_RC_CONF_FILE=/etc/rc.conf
fi

# Install mDNSResponder and mDNSResponder_nss
pkg install -qy mDNSResponder_nss

# Modify the Name Server Switch configuration file
sed -i '' -e 's/^hosts: files dns/hosts: files mdns dns/' /etc/nsswitch.conf

# mDNSResponder configuration
sysrc -f "$MDNSD_RC_CONF_FILE" mdnsd_enable=YES
sysrc -f "$MDNSRESPONDERPOSIX_RC_CONF_FILE" mdnsresponderposix_enable=YES
sysrc -f "$MDNSRESPONDERPOSIX_RC_CONF_FILE" \
	mdnsresponderposix_flags='-f /usr/local/etc/mDNSResponderServices.conf'

cat > /usr/local/etc/mDNSResponderServices.conf << END
#
# Services file parsed by mDNSResponderPosix.
#
# Lines beginning with '#' are comments/ignored.
# Blank lines indicate the end of a service record specification.
# The first character of the service name can be a '#' if you escape it with
# backslash to distinguish if from a comment line.
# ie, "\#serviceName" will be registered as "#serviceName".
# Note that any line beginning with white space is considered a blank line.
#
# The record format is:
#
# <service name>
# <type>.<protocol> <optional domain>
# <port number>
# <zero or more strings for the text record, one string per line>
#
# <One or more blank lines between records>
#
# Examples shown below.

Vagrant
_ssh._tcp.
22

Vagrant
_sftp-ssh._tcp.
22
END
