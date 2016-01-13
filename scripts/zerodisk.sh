#!/bin/sh

# Delete itself
rm -f /tmp/script.sh

# TODO: Set the root password from bsdinstall and install everything as root
# Set root password
echo 'vagrant' | pw usermod root -h 0

# Zero out the free space to save space in the final image
echo "Zeroing device to make space..."
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Block until the empty file has been removed, otherwise, packer
# will try to kill the box while the disk is still full and that's bad
sync
