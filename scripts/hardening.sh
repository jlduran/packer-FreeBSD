#!/bin/sh
set -e

if [ -e /tmp/rc-local ]; then
	BLACKLISTD_RC_CONF_FILE=/etc/rc.conf.local
	CLEARTMP_RC_CONF_FILE=/etc/rc.conf.local
	IPFW_RC_CONF_FILE=/etc/rc.conf.local
	NETOPTIONS_RC_CONF_FILE=/etc/rc.conf.local
	ROUTING_RC_CONF_FILE=/etc/rc.conf.local
	SSHD_RC_CONF_FILE=/etc/rc.conf.local
	SYSLOGD_RC_CONF_FILE=/etc/rc.conf.local
elif [ -e /tmp/rc-vendor ]; then
	BLACKLISTD_RC_CONF_FILE=/etc/defaults/vendor.conf
	CLEARTMP_RC_CONF_FILE=/etc/defaults/vendor.conf
	IPFW_RC_CONF_FILE=/etc/defaults/vendor.conf
	NETOPTIONS_RC_CONF_FILE=/etc/defaults/vendor.conf
	ROUTING_RC_CONF_FILE=/etc/defaults/vendor.conf
	SSHD_RC_CONF_FILE=/etc/defaults/vendor.conf
	SYSLOGD_RC_CONF_FILE=/etc/defaults/vendor.conf
elif [ -e /tmp/rc-name ]; then
	BLACKLISTD_RC_CONF_FILE=/etc/rc.conf.d/blacklistd
	CLEARTMP_RC_CONF_FILE=/etc/rc.conf.d/cleartmp
	IPFW_RC_CONF_FILE=/etc/rc.conf.d/ipfw
	NETOPTIONS_RC_CONF_FILE=/etc/rc.conf.d/netoptions
	ROUTING_RC_CONF_FILE=/etc/rc.conf.d/routing
	SSHD_RC_CONF_FILE=/etc/rc.conf.d/sshd
	SYSLOGD_RC_CONF_FILE=/etc/rc.conf.d/syslogd
else
	BLACKLISTD_RC_CONF_FILE=/etc/rc.conf
	CLEARTMP_RC_CONF_FILE=/etc/rc.conf
	IPFW_RC_CONF_FILE=/etc/rc.conf
	NETOPTIONS_RC_CONF_FILE=/etc/rc.conf
	ROUTING_RC_CONF_FILE=/etc/rc.conf
	SSHD_RC_CONF_FILE=/etc/rc.conf
	SYSLOGD_RC_CONF_FILE=/etc/rc.conf
fi

# Disable weak SSH keys
sysrc -f "$SSHD_RC_CONF_FILE" sshd_ecdsa_enable=NO
rm -f /etc/ssh/ssh_host_ecdsa_key*

# Setup firewall
sysrc -f "$IPFW_RC_CONF_FILE" firewall_enable=YES
sysrc -f "$IPFW_RC_CONF_FILE" firewall_quiet=YES
sysrc -f "$IPFW_RC_CONF_FILE" firewall_type=workstation
sysrc -f "$IPFW_RC_CONF_FILE" firewall_myservices=ssh/tcp # XXX: mDNS
sysrc -f "$IPFW_RC_CONF_FILE" firewall_allowservices=any
sysrc -f "$IPFW_RC_CONF_FILE" firewall_logdeny=YES

# Setup blacklistd
sysrc -f "$BLACKLISTD_RC_CONF_FILE" blacklistd_enable=YES
sysrc -f "$BLACKLISTD_RC_CONF_FILE" blacklistd_flags=-r
touch /etc/ipfw-blacklist.rc
chmod 0600 /etc/ipfw-blacklist.rc
sed -i '' -e 's/^#UseBlacklist no/UseBlacklist yes/' /etc/ssh/sshd_config
sed -i '' -e 's/ftpd -l$/ftpd -B -l/' /etc/inetd.conf

# Configure SSH server
sed -i '' -e 's/^#AllowAgentForwarding yes/AllowAgentForwarding no/' \
	/etc/ssh/sshd_config
sed -i '' -e 's/^#AllowTcpForwarding yes/AllowTcpForwarding no/' \
	/etc/ssh/sshd_config
sed -i '' -e 's/^#Compression delayed/Compression no/' \
	/etc/ssh/sshd_config
sed -i '' -e 's/^#ClientAliveCountMax 3/ClientAliveCountMax 2/' \
	/etc/ssh/sshd_config
sed -i '' -e 's/^#LogLevel INFO/LogLevel VERBOSE/' \
	/etc/ssh/sshd_config
sed -i '' -e 's/^#MaxAuthTries 6/MaxAuthTries 2/' \
	/etc/ssh/sshd_config
sed -i '' -e 's/^#MaxSessions 10/MaxSessions 2/' \
	/etc/ssh/sshd_config
sed -i '' -e 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' \
	/etc/ssh/sshd_config
sed -i '' -e 's/^#KbdInteractiveAuthentication yes/KbdInteractiveAuthentication no/' \
	/etc/ssh/sshd_config
sed -i '' -e 's/^#UsePAM yes/UsePAM no/' \
	/etc/ssh/sshd_config
sed -i '' -e 's/^#TCPKeepAlive yes/TCPKeepAlive no/' \
	/etc/ssh/sshd_config
sed -i '' -e 's/^#VersionAddendum .*$/VersionAddendum none/' \
	/etc/ssh/sshd_config
sed -i '' -e 's/^#X11Forwarding yes/X11Forwarding no/' \
	/etc/ssh/sshd_config

# Routing options
sysrc -f "$ROUTING_RC_CONF_FILE" icmp_drop_redirect=YES

# Additional TCP/IP options
sysrc -f "$NETOPTIONS_RC_CONF_FILE" ipv6_privacy=YES
sysrc -f "$NETOPTIONS_RC_CONF_FILE" tcp_keepalive=NO
sysrc -f "$NETOPTIONS_RC_CONF_FILE" tcp_drop_synfin=YES

# Additional rc.conf options
sysrc -f "$CLEARTMP_RC_CONF_FILE" clear_tmp_enable=YES
sysrc -f "$SYSLOGD_RC_CONF_FILE" syslogd_flags=-ss

# Change sysctl default values
cat > /etc/sysctl.conf <<- EOF
debug.debugger_on_panic=0
debug.trace_on_panic=1
hw.kbd.keymap_restrict_change=4
kern.elf64.aslr.enable=1
kern.elf64.aslr.honor_sbrk=0
kern.elf64.aslr.pie_enable=1
kern.ipc.soacceptqueue=1024
kern.panic_reboot_wait_time=0
kern.randompid=1
net.inet.ip.check_interface=1
net.inet.ip.process_options=0
net.inet.ip.random_id=1
net.inet.ip.redirect=0
net.inet.tcp.blackhole=2
net.inet.tcp.ecn.enable=1
net.inet.tcp.icmp_may_rst=0
net.inet.tcp.mssdflt=1460
net.inet.tcp.nolocaltimewait=1
net.inet.tcp.path_mtu_discovery=0
net.inet.udp.blackhole=1
net.inet6.icmp6.nodeinfo=0
net.inet6.icmp6.rediraccept=0
net.inet6.ip6.redirect=0
security.bsd.allow_destructive_dtrace=0
security.bsd.hardlink_check_gid=1
security.bsd.hardlink_check_uid=1
security.bsd.see_jail_proc=0
security.bsd.see_other_gids=0
security.bsd.see_other_uids=0
security.bsd.stack_guard_page=1
security.bsd.unprivileged_proc_debug=0
security.bsd.unprivileged_read_msgbuf=0
EOF

# Change umask
sed -i '' -e 's/:umask=022:/:umask=027:/g' /etc/login.conf

# Remove toor user
pw userdel toor

# Secure ttys
sed -i '' -e 's/ secure/ insecure/g' /etc/ttys

# Secure newsyslog
sed -i '' -e 's|^/var/log/init.log			644|/var/log/init.log			640|' \
	/etc/newsyslog.conf
sed -i '' -e 's|^/var/log/messages			644|/var/log/messages			640|' \
	/etc/newsyslog.conf
sed -i '' -e 's|^/var/log/devd.log			644|/var/log/devd.log			640|' \
	/etc/newsyslog.conf
