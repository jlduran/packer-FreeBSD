#!/bin/sh

# Install python
pkg install -y python py27-pip

# Install root certs
pkg install -y ca_root_nss
