#!/bin/sh
set -e

# Install python and root certificates
pkg install -qy python ca_root_nss
