#!/bin/sh -e

# Install bash & sudo
pkg install -y bash sudo
echo 'fdesc		/dev/fd		fdescfs	rw	0	0' >> /etc/fstab

# Use bash shell
chsh -s /usr/local/bin/bash vagrant

# Configure sudo to allow the vagrant user
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /usr/local/etc/sudoers.d/vagrant

# Configure the vagrant ssh key
mkdir /home/vagrant/.ssh
fetch -am --no-verify-peer -o /home/vagrant/.ssh/authorized_keys \
	'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chown -R 1001 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys

# NFS configuration
echo 'rpcbind_enable="YES"' > /etc/rc.conf.d/rpcbind
echo 'nfs_server_enable="YES"' > /etc/rc.conf.d/nfsd
echo 'mountd_flags="-r"' > /etc/rc.conf.d/mountd
touch /etc/exports

# Set the build time
date > /etc/vagrant_box_build_time
