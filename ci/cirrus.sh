#!/bin/sh -e

# Prerequisites
pkg install -y git packer vagrant virtualbox-ose-nox11

# Instructions
git clone --single-branch -b 12.0 https://github.com/jlduran/packer-FreeBSD.git
cd packer-FreeBSD
cp variables.json.sample variables.json
packer build -var-file=variables.json template.json
