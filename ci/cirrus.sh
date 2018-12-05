#!/bin/sh -e

# Prerequisites
pkg install -y git packer vagrant virtualbox-ose-nox11
kldload vboxdrv
kldload vboxnetflt:ng_vboxnetflt
kldload vboxnetadp
pw groupmod vboxusers -m "$(whoami)"
chown root:vboxusers /dev/vboxnetctl
chmod 0660 /dev/vboxnetctl

# Instructions
git clone --single-branch -b 12.0 https://github.com/jlduran/packer-FreeBSD.git
cd packer-FreeBSD
cp variables.json.sample variables.json
packer build -var-file=variables.json template.json
