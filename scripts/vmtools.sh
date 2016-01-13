#!/bin/sh

case "$PACKER_BUILDER_TYPE" in

	virtualbox-iso|virtualbox-ovf)
		pkg install -y virtualbox-ose-additions

		echo 'vboxguest_enable="YES"' > /etc/rc.conf.d/vboxguest
		echo 'vboxnet_enable="YES"' > /etc/rc.conf.d/vboxnet
		echo 'vboxservice_enable="YES"' > /etc/rc.conf.d/vboxservice

		cat >> /boot/loader.conf.local <<- END
		#VIRTUALBOX-BEGIN
		vboxdrv_load="YES"
		virtio_balloon_load="YES"
		virtio_blk_load="YES"
		virtio_scsi_load="YES"
		#VIRTUALBOX-END
		END
		;;

	vmware-iso|vmware-vmx)
		pkg install -y open-vm-tools-nox11

		echo 'vmware_guest_vmblock_enable="YES"' >> /etc/rc.conf
		echo 'vmware_guest_vmhgfs_enable="YES"' >> /etc/rc.conf
		echo 'vmware_guest_vmmemctl_enable="YES"' >> /etc/rc.conf
		echo 'vmware_guest_vmxnet_enable="YES"' >> /etc/rc.conf
		echo 'vmware_guestd_enable="YES"' >> /etc/rc.conf
		;;

	parallels-iso|parallels-pvm)
		mkdir /tmp/parallels
		mount -o loop /home/vagrant/prl-tools-lin.iso /tmp/parallels
		/tmp/parallels/install --install-unattended-with-deps
		umount /tmp/parallels
		rmdir /tmp/parallels
		rm /home/vagrant/*.iso
		;;

	*)
		echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected."
		echo "Known types are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm."
		;;

esac
