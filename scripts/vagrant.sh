#!/bin/sh

# install bash & sudo
pkg install -y bash sudo

# fstab
echo 'fdesc		/dev/fd		fdescfs	rw	0	0' >> /etc/fstab

# use bash shell
chsh -s /usr/local/bin/bash vagrant

# install vagrant keys
mkdir /home/vagrant/.ssh
fetch -am --no-verify-peer -o /home/vagrant/.ssh/authorized_keys \
	'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# enable passwordless sudo
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /usr/local/etc/sudoers.d/vagrant

# nfs configuration
echo 'rpcbind_enable="YES"' > /etc/rc.conf.d/rpcbind
echo 'nfs_server_enable="YES"' > /etc/rc.conf.d/nfsd
echo 'mountd_flags="-r"' > /etc/rc.conf.d/mountd
