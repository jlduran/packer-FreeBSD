#!/bin/sh -e

USR_LOCAL_PATH=/usr/local
RC_CONF_PATH=/etc/rc.conf.d
# TODO: Try using RC_CONF_PATH after freebsd/freebsd@f846b0afd19b9ee1cb333f1944711bb226aa938f
RC_CONF_LOCAL_FILE=/etc/rc.conf.local
SSHD_RC_CONF_FILE="$RC_CONF_PATH/sshd"
BLACKLISTD_RC_CONF_FILE="$RC_CONF_PATH/blacklistd"

# Setup firewall
sysrc -f "$RC_CONF_LOCAL_FILE" firewall_enable=YES
sysrc -f "$RC_CONF_LOCAL_FILE" firewall_quiet=YES
sysrc -f "$RC_CONF_LOCAL_FILE" firewall_type=workstation
sysrc -f "$RC_CONF_LOCAL_FILE" firewall_myservices=ssh/tcp # XXX: mDNS
sysrc -f "$RC_CONF_LOCAL_FILE" firewall_allowservices=any
sysrc -f "$RC_CONF_LOCAL_FILE" firewall_logdeny=YES

# Setup blacklistd
sysrc -f "$BLACKLISTD_RC_CONF_FILE" blacklistd_enable=YES
sysrc -f "$BLACKLISTD_RC_CONF_FILE" blacklistd_flags=-r
touch /etc/ipfw-blacklist.rc
chmod 0600 /etc/ipfw-blacklist.rc
sed -i '' 's|#UseBlacklist no|UseBlacklist yes|g' /etc/ssh/sshd_config
sed -i '' 's|ftpd -l$|ftpd -B -l|g' /etc/inetd.conf

# Disable weak SSH keys
sysrc -f "$SSHD_RC_CONF_FILE" sshd_ecdsa_enable=NO

# Configure SSH server
# ---> KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
# ---> Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
# ---> MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160,umac-128@openssh.com
sed -i '' 's|#LogLevel INFO|LogLevel VERBOSE|g' /etc/ssh/sshd_config
sed -i '' 's|#MaxAuthTries 6|MaxAuthTries 2|g' /etc/ssh/sshd_config
sed -i '' 's|#MaxSessions 10|MaxSessions 2|g' /etc/ssh/sshd_config
sed -i '' 's|#ChallengeResponseAuthentication yes|ChallengeResponseAuthentication no|g' /etc/ssh/sshd_config
sed -i '' 's|#UsePAM yes|UsePAM no|g' /etc/ssh/sshd_config
sed -i '' 's|#AllowAgentForwarding yes|AllowAgentForwarding no|g' /etc/ssh/sshd_config
sed -i '' 's|#AllowTcpForwarding yes|AllowTcpForwarding no|g' /etc/ssh/sshd_config
sed -i '' 's|#X11Forwarding yes|X11Forwarding no|g' /etc/ssh/sshd_config
sed -i '' 's|#TCPKeepAlive yes|TCPKeepAlive no|g' /etc/ssh/sshd_config
sed -i '' 's|#Compression delayed|Compression no|g' /etc/ssh/sshd_config
sed -i '' 's|#ClientAliveCountMax 3|ClientAliveCountMax 2|g' /etc/ssh/sshd_config
sed -i '' 's|#VersionAddendum .*$|VersionAddendum none|g' /etc/ssh/sshd_config

# Change sysctl default values
cat > /etc/sysctl.conf <<- EOF
debug.debugger_on_panic=0
debug.trace_on_panic=1
hw.kbd.keymap_restrict_change=4
kern.ipc.somaxconn=1024
kern.panic_reboot_wait_time=0
net.inet.icmp.drop_redirect=1
net.inet.ip.check_interface=1
net.inet.ip.process_options=0
net.inet.ip.random_id=1
net.inet.ip.redirect=0
net.inet.sctp.blackhole=2
net.inet.tcp.always_keepalive=0
net.inet.tcp.blackhole=2
net.inet.tcp.drop_synfin=1
net.inet.tcp.ecn.enable=1
net.inet.tcp.icmp_may_rst=0
net.inet.tcp.mssdflt=1440
net.inet.tcp.nolocaltimewait=1
net.inet.tcp.path_mtu_discovery=0
net.inet.udp.blackhole=1
net.inet6.icmp6.nodeinfo=0
net.inet6.icmp6.rediraccept=0
net.inet6.ip6.prefer_tempaddr=1
net.inet6.ip6.redirect=0
net.inet6.ip6.use_tempaddr=1
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
sed -i '' 's|:umask=022:|:umask=027:|g' /etc/login.conf

# Remove toor user
pw userdel toor

# Secure ttys
sed -i '' 's/ secure/ insecure/g' /etc/ttys
