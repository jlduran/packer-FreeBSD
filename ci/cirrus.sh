#!/bin/sh -e

# Prerequisites
pkg install -y git-lite packer vagrant virtualbox-ose-nox11

## Virtualbox extra steps:
## https://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/virtualization-host-virtualbox.html
pw groupmod vboxusers -m "$(whoami)"
service vboxnet onestart
chown root:vboxusers /dev/vboxnetctl
chmod 0660 /dev/vboxnetctl
service -R

# Instructions
git clone --single-branch -b 12.0 https://github.com/jlduran/packer-FreeBSD.git
cd packer-FreeBSD
cp variables.json.sample variables.json
packer build -var-file=variables.json template.json
