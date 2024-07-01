#!/bin/sh
set -e

if [ -e /tmp/rc-local ]; then
	DBUS_RC_CONF_FILE=/etc/rc.conf.local
	VBOXGUEST_RC_CONF_FILE=/etc/rc.conf.local
	VBOXSERVICE_RC_CONF_FILE=/etc/rc.conf.local
	VMWARE_GUESTD_RC_CONF_FILE=/etc/rc.conf.local
elif [ -e /tmp/rc-vendor ]; then
	DBUS_RC_CONF_FILE=/etc/defaults/vendor.conf
	VBOXGUEST_RC_CONF_FILE=/etc/defaults/vendor.conf
	VBOXSERVICE_RC_CONF_FILE=/etc/defaults/vendor.conf
	VMWARE_GUESTD_RC_CONF_FILE=/etc/defaults/vendor.conf
elif [ -e /tmp/rc-name ]; then
	DBUS_RC_CONF_FILE=/usr/local/etc/rc.conf.d/dbus
	VBOXGUEST_RC_CONF_FILE=/usr/local/etc/rc.conf.d/vboxguest
	VBOXSERVICE_RC_CONF_FILE=/usr/local/etc/rc.conf.d/vboxservice
	VMWARE_GUESTD_RC_CONF_FILE=/usr/local/etc/rc.conf.d/vmware_guestd
	mkdir -p /usr/local/etc/rc.conf.d
else
	DBUS_RC_CONF_FILE=/etc/rc.conf
	VBOXGUEST_RC_CONF_FILE=/etc/rc.conf
	VBOXSERVICE_RC_CONF_FILE=/etc/rc.conf
	VMWARE_GUESTD_RC_CONF_FILE=/etc/rc.conf
fi

case "$PACKER_BUILDER_TYPE" in

	virtualbox-iso|virtualbox-ovf)
		# pkg install -qy virtualbox-ose-additions-nox11

		# sysrc -f "$DBUS_RC_CONF_FILE" dbus_enable=YES
		# sysrc -f "$VBOXGUEST_RC_CONF_FILE" vboxguest_enable=YES
		# sysrc -f "$VBOXSERVICE_RC_CONF_FILE" vboxservice_enable=YES

		cat >> /boot/loader.conf <<- END
		# VIRTUALBOX-BEGIN
		#vboxdrv_load="YES"
		# VIRTUALBOX-END
		END
		;;

	vmware-iso|vmware-vmx)
		pkg install -qy open-vm-tools-nox11

		cat >> "$VMWARE_GUESTD_RC_CONF_FILE" <<- END
		vmware_guest_vmblock_enable="YES"
		vmware_guest_vmmemctl_enable="YES"
		vmware_guest_vmxnet_enable="YES"
		vmware_guestd_enable="YES"
		END
		;;

	parallels-iso|parallels-pvm)
		;;

	qemu)
		pkg install -qy qemu-guest-agent
		sysrc qemu_guest_agent_enable=YES
		sysrc qemu_guest_agent_flags="-d -v -l /var/log/qemu-ga.log"
		;;

	*)
		echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected."
		echo "Known types are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm."
		;;

esac
