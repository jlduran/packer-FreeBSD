#!/bin/sh

# delete itself
rm -f /tmp/script.sh

# set root password
echo 'vagrant' | pw usermod root -h 0

# zero out the free space to save space in the final image
echo "Zeroing device to make space..."
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# block until the empty file has been removed, otherwise, packer
# will try to kill the box while the disk is still full and that's bad
sync
