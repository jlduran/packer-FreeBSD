#!/bin/sh -e

RC_CONF_DIR=/usr/local/etc/rc.conf.d

case "$PACKER_BUILDER_TYPE" in

	virtualbox-iso|virtualbox-ovf)
		pkg install -y virtualbox-ose-additions-nox11

		mkdir -p "$RC_CONF_DIR"
		sysrc -f "$RC_CONF_DIR"/dbus dbus_enable=YES
		sysrc -f "$RC_CONF_DIR"/vboxguest vboxguest_enable=YES
		sysrc -f "$RC_CONF_DIR"/vboxnet vboxnet_enable=YES
		sysrc -f "$RC_CONF_DIR"/vboxservice vboxservice_enable=YES

		cat >> /boot/loader.conf <<- END
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

		cat >> "$RC_CONF_DIR"/vmware_guestd <<- END
		vmware_guest_vmblock_enable="YES"
		vmware_guest_vmmemctl_enable="YES"
		vmware_guest_vmxnet_enable="YES"
		vmware_guestd_enable="YES"
		END
		;;

	parallels-iso|parallels-pvm)
		mkdir /tmp/parallels
		mount -o loop /root/prl-tools-lin.iso /tmp/parallels
		/tmp/parallels/install --install-unattended-with-deps
		umount /tmp/parallels
		rmdir /tmp/parallels
		rm /root/*.iso
		;;

	*)
		echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected."
		echo "Known types are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm."
		;;

esac
