#!/bin/sh

case "$PACKER_BUILDER_TYPE" in

	virtualbox-iso|virtualbox-ovf)
		pkg install -y virtualbox-ose-additions

		echo 'vboxguest_enable="YES"' > /etc/rc.conf.d/vboxguest
		echo 'vboxnet_enable="YES"' > /etc/rc.conf.d/vboxnet
		echo 'vboxservice_enable="YES"' > /etc/rc.conf.d/vboxservice

		cat >> /boot/loader.conf.local <<- END
		#VIRTUALBOX-BEGIN
		if_vtnet_load="YES"
		vboxdrv_load="YES"
		virtio_balloon_load="YES"
		virtio_blk_load="YES"
		virtio_scsi_load="YES"
		#VIRTUALBOX-END
		END
		;;

	vmware-iso|vmware-vmx)
		mkdir /tmp/vmfusion
		mkdir /tmp/vmfusion-archive
		mount -o loop /home/vagrant/linux.iso /tmp/vmfusion
		tar xzf /tmp/vmfusion/VMwareTools-*.tar.gz -C /tmp/vmfusion-archive
		/tmp/vmfusion-archive/vmware-tools-distrib/vmware-install.pl --default
		umount /tmp/vmfusion
		rm -rf /tmp/vmfusion
		rm -rf /tmp/vmfusion-archive
		rm /home/vagrant/*.iso
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
