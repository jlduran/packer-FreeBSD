#!/bin/sh

# install python
pkg install -y python py27-pip

# install root certs
pkg install -y ca_root_nss
