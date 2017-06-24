packer-FreeBSD
==============

This repository contains the necessary tools to build a Vagrant-ready
FreeBSD virtual machine using Packer.

There are [official FreeBSD] VMs available from the Atlas Cloud.

Pre-requisites
--------------

- [Packer]

- [Vagrant]

- [VirtualBox] or [VMWare Fusion]

Instructions
------------

To create a box:

1.  Clone this repository:

        $ git clone https://github.com/jlduran/packer-FreeBSD.git
        $ cd packer-FreeBSD

2.  _(Optional)_ Adjust variables.  See [Build Options](#build-options)
    for more information.

3.  Build the box:

        $ packer build -var-file=variables.json template.json

4.  Add it to the list of Vagrant boxes:

        $ vagrant box add builds/FreeBSD-11.0-RELEASE-amd64.box --name FreeBSD-11.0-RELEASE-amd64

------------------------------------------------------------------------

### Build Options

You can adjust the following variables in `variables.json`:

```json
{
  "cpus": "1",
  "disk_size": "10240",
  "memory": "512",
  "release": "11.0",
  "branch": "-RELEASE",
  "snapshot": "",
  "revision": "",
  "directory": "releases",
  "arch": "amd64",
  "guest_os_type": "FreeBSD_64",
  "filesystem": "ufs",
  "mirror": "http://ftp.freebsd.org/pub/FreeBSD"
}
```

-   `cpus` is the number of CPUs assigned.  _Default:_ `1`

-   `disk_size` is the HDD size.  _Default:_ `10240`

-   `memory` is the amount of RAM assigned.  _Default:_ `512`

-   `release` is the FreeBSD version number.  _Default:_ `11.0`

-   `branch` used in conjunction with `snapshot`, `revision` and
    `directory`.  _Default:_ `-RELEASE`

    See FreeBSD's [Release Branches] for more information.  Possible
    values are:

    | Branch                  | Directory   |
    | ------                  | ---------   |
    | `-CURRENT`              | `snapshots` |
    | `-STABLE`               | `snapshots` |
    | `-ALPHA1`, `-ALPHA2`, … | `snapshots` |
    | `-BETA1`, `-BETA2`, …   | `releases`  |
    | `-RC1`, `-RC2`, …       | `releases`  |
    | `-RELEASE`              | `releases`  |

-   `arch` is the target architecture (`i386` or `amd64`).  _Default:_
    `amd64`

-   `guest_os_type` (VirtualBox) used in conjunction with `arch`
    (`FreeBSD` or `FreeBSD_64`).  See [packer's
    documentation](https://www.packer.io/docs/builders/virtualbox-iso.html#guest_os_type).
    _Default:_ `FreeBSD_64`

-   `filesystem` is the file system type (`ufs` or `zfs`).  _Default:_
    `ufs`

-   `mirror` is the preferred FreeBSD mirror.  _Default:_
    `http://ftp.freebsd.org/pub/FreeBSD`

You can also select which components you wish to install.  By default,
it runs the following provisioning scripts:

| Name      | Description                                                               |
| ----      | -----------                                                               |
| `update`  | Updates to the latest patch level (if applicable) and the latest packages |
| `vagrant` | Vagrant-related configuration                                             |
| `avahi`   | Enables zero-configuration networking                                     |
| `ansible` | Installs python and CA Root certificates                                  |
| `ports`   | Installs the FreeBSD ports tree                                           |
| `vmtools` | Virtual Machine-specific utilities                                        |
| `cleanup` | Cleanup script                                                            |

### Handling `.iso` and `.box` files

Packer will automatically download the `.iso` image if it does not find
the right one under the `iso` directory.  Optionally, you can download
the `.iso` image and save it to the `iso` directory.

`.box` files will be created under the `builds` directory.

[official FreeBSD]: https://atlas.hashicorp.com/freebsd
[Release Branches]: https://www.freebsd.org/doc/en/books/dev-model/release-branches.html
[Packer]: https://www.packer.io/docs/installation.html
[Vagrant]: https://www.vagrantup.com/downloads.html
[VirtualBox]: https://www.virtualbox.org/wiki/Downloads
[VMWare Fusion]: http://www.vmware.com/products/fusion/
