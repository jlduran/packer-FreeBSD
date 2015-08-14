#!/bin/sh -x

NAME=$1

# create disks
if [ -e /dev/ada0 ]; then
	DISKSLICE=ada0 # VirtualBox
else
	DISKSLICE=da0  # VMWare
fi

gpart create -s gpt $DISKSLICE
gpart add -b 34 -s 94 -t freebsd-boot $DISKSLICE
gpart add -t freebsd-zfs -l disk0 $DISKSLICE
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 $DISKSLICE

zpool create -o altroot=/mnt -o cachefile=/tmp/zpool.cache zroot /dev/gpt/disk0
zpool set bootfs=zroot zroot

zfs set checksum=fletcher4 zroot

# set up zfs pools
zfs create zroot/usr
zfs create zroot/usr/home
zfs create zroot/var
zfs create -o compression=on   -o exec=on  -o setuid=off zroot/tmp
zfs create -o compression=on   -o exec=on  -o setuid=off zroot/usr/ports
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/distfiles
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/packages
zfs create -o compression=on   -o exec=off -o setuid=off zroot/usr/src
zfs create -o compression=on   -o exec=off -o setuid=off zroot/var/crash
zfs create -o compression=off  -o exec=off -o setuid=off zroot/var/db
zfs create -o compression=on   -o exec=on  -o setuid=off zroot/var/db/pkg
zfs create -o compression=off  -o exec=off -o setuid=off zroot/var/empty
zfs create -o compression=on   -o exec=off -o setuid=off zroot/var/log
zfs create -o compression=gzip -o exec=off -o setuid=off zroot/var/mail
zfs create -o compression=off  -o exec=off -o setuid=off zroot/var/run
zfs create -o compression=on   -o exec=on  -o setuid=off zroot/var/tmp

# fixup
chmod 1777 /mnt/zroot/tmp
cd /mnt/zroot; ln -s usr/home home
chmod 1777 /mnt/zroot/var/tmp

# set up swap
zfs create -V 1G zroot/swap
zfs set org.freebsd:swap=on zroot/swap
zfs set checksum=off zroot/swap
swapon /dev/zvol/zroot/swap

# install the OS
cd /usr/freebsd-dist
cat base.txz | tar --unlink -xpJf - -C /mnt/zroot
cat kernel.txz | tar --unlink -xpJf - -C /mnt/zroot
if [ "$(uname -p)" = 'amd64' ]; then
	cat lib32.txz | tar --unlink -xpJf - -C /mnt/zroot
fi

cp /tmp/zpool.cache /mnt/zroot/boot/zfs/zpool.cache

zfs set readonly=on zroot/var/empty

# zfs support
echo 'zfs_enable="YES"' > /mnt/zroot/etc/rc.conf.d/zfs

# basic network options
# Vagrant expects these to be in /etc/rc.conf
# echo 'hostname="${NAME}"' > /mnt/zroot/etc/rc.conf.d/hostname
# echo 'ifconfig_vtnet0="DHCP"' > /mnt/zroot/etc/rc.conf.d/network
echo 'hostname="${NAME}"' >> /mnt/zroot/etc/rc.conf
echo 'ifconfig_vtnet0="DHCP"' >> /mnt/zroot/etc/rc.conf

# network daemon (miscellaneous)
# Keep compatibility with cloud providers
# echo 'sshd_enable="YES"' > /mnt/zroot/etc/rc.conf.d/sshd
echo 'sshd_enable="YES"' >> /mnt/zroot/etc/rc.conf

# tune and boot from zfs
cat >> /mnt/zroot/boot/loader.conf << END
console="vidconsole,comconsole"
autoboot_delay="10"
END

cat >> /mnt/zroot/boot/loader.conf.local << END
#ZFS-BEGIN
zfs_load="YES"
vfs.root.mountfrom="zfs:zroot"
vm.kmem_size="200M"
vm.kmem_size_max="200M"
vfs.zfs.arc_max="40M"
vfs.zfs.vdev.cache.size="5M"
#ZFS-END
END

# zfs doesn't use an fstab, but some rc scripts expect one
touch /mnt/zroot/etc/fstab

# set up user accounts
zfs create zroot/usr/home/vagrant
echo 'vagrant' | pw -V /mnt/zroot/etc useradd vagrant -c 'Vagrant User' -d /home/vagrant -G wheel -s /bin/sh -h 0
chown 1001:1001 /mnt/zroot/home/vagrant

#
zfs unmount -a
zfs set mountpoint=legacy zroot
zfs set mountpoint=/tmp zroot/tmp
zfs set mountpoint=/usr zroot/usr
zfs set mountpoint=/var zroot/var

# reboot
reboot
