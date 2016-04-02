#!/bin/sh -e

# Install python
pkg install -y python

# Install root certs
pkg install -y ca_root_nss
