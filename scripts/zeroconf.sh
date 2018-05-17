#!/bin/sh -e

if [ -z "$RC_CONF_FILE" ] && [ -z "$RC_CONF_DIR" ]; then
	RC_CONF_FILE=/etc/rc.conf
fi

# Install mDNSResponder and mDNSResponder_nss
pkg install -y mDNSResponder_nss

# Modify the Name Server Switch configuration file
sed -i '' -e 's/^hosts: files dns/hosts: files mdns dns/' /etc/nsswitch.conf

# mDNSResponder configuration
if [ ! -z "$RC_CONF_DIR" ]; then
	mkdir -p "$RC_CONF_DIR"
	sysrc -f "$RC_CONF_DIR"/mdnsd mdnsd_enable=YES
	sysrc -f "$RC_CONF_DIR"/mdnsresponderposix mdnsresponderposix_enable=YES
	sysrc -f "$RC_CONF_DIR"/mdnsresponderposix \
		mdnsresponderposix_flags='-f /usr/local/etc/mDNSResponderServices.conf'
else
	sysrc -f "$RC_CONF_FILE" mdnsd_enable=YES
	sysrc -f "$RC_CONF_FILE" mdnsresponderposix_enable=YES
	sysrc -f "$RC_CONF_FILE" \
		mdnsresponderposix_flags='-f /usr/local/etc/mDNSResponderServices.conf'
fi

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
