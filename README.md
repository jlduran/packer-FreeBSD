packer-FreeBSD
==============

This repository contains the necessary tools to build a base FreeBSD
virtual machine using Packer.

There are [official FreeBSD] vagrant VMs available from the Atlas Cloud.

Pre-requisites
--------------

- [Packer]

        $ brew install packer

- [Vagrant]

- [VirtualBox] or [VMWare Fusion]

Instructions
------------

To create a box:

1.  Clone this repository:

        $ git clone https://github.com/jlduran/packer-FreeBSD.git

2.  _(Optional)_ Adjust the settings by editing the `FreeBSD.json` file.
    This file is located under the `packer` directory.

3.  Build the box:

        $ cd packer-FreeBSD
        $ packer build packer/FreeBSD.json

4.  Add it to the list of Vagrant boxes:

        $ vagrant box add builds/FreeBSD-10.2-RELEASE-amd64.box --name FreeBSD-10.2-RELEASE-amd64

### Handling `.iso` and `.box` files

Packer will automatically download the `.iso` image if it does not find
the right one under the `iso` directory.  Optionally, you can download
the `.iso` image and save it to the `iso` directory.

`.box` files will be created under the `builds` directory.

Once the box is created, the `.iso` image and the `.box` files can be
discarded to free up some space.

### NFS Synced Folders

Instead of typing the password on every `vagrant up` in order to modify
system files, the `sudoers` file can be modified to avoid it:

    $ sudo visudo

Add the following blocks into their respective sections:

    # Cmnd alias specification
    Cmnd_Alias	VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports
    Cmnd_Alias	VAGRANT_NFSD = /sbin/nfsd restart
    Cmnd_Alias	VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports

    ...

    # User privilege specification
    ...
    %staff	ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE

[official FreeBSD]: https://atlas.hashicorp.com/freebsd
[Packer]: https://www.packer.io
[Vagrant]: https://www.vagrantup.com
[VirtualBox]: https://www.virtualbox.org
[VMWare Fusion]: http://www.vmware.com/products/fusion/
