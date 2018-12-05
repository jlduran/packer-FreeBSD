#!/bin/sh -e

# Prerequisites
pkg install -y git packer vagrant virtualbox-ose

# Instructions
git clone https://github.com/jlduran/packer-FreeBSD.git
cd packer-FreeBSD
cp variables.json.sample variables.json
packer build -var-file=variables.json template.json
