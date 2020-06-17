#!/bin/sh -e

# Install bash & sudo
pkg install -qy bash sudo

# Create the vagrant user with a password of vagrant
pw groupadd vagrant -g 1001
mkdir -p /home/vagrant
pw useradd -n vagrant -u 1001 -c 'Vagrant User' -d /home/vagrant \
	-g 1001 -G 0 -m -M 0755 -w yes -s /usr/local/bin/bash

# Configure sudo to allow the vagrant user
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /usr/local/etc/sudoers.d/vagrant
chmod 0440 /usr/local/etc/sudoers.d/vagrant

# Configure passwordless su to wheel users
sed -i '' -e '/pam_group.so/ a\
auth		sufficient	pam_group.so		trust use_uid ruser' \
	/etc/pam.d/su

# Configure the vagrant ssh key
mkdir -m 0700 /home/vagrant/.ssh
fetch -am --no-verify-peer -o /home/vagrant/.ssh/authorized_keys \
	'https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub'
chown -R 1001 /home/vagrant/.ssh
chmod 0600 /home/vagrant/.ssh/authorized_keys

# Set the build time
date > /etc/vagrant_box_build_time
