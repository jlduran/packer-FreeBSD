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

        $ vagrant box add builds/FreeBSD-11.1-RELEASE-amd64.box --name FreeBSD-11.1-RELEASE-amd64

------------------------------------------------------------------------

### Build Options

You can adjust the following variables in `variables.json`:

```json
{
  "cpus": "1",
  "disk_size": "10240",
  "memory": "512",
  "release": "11.1",
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

-   `release` is the FreeBSD version number.  _Default:_ `11.1`

-   `branch` used in conjunction with `snapshot`, `revision` and
    `directory`.  _Default:_ `-RELEASE`

    See FreeBSD's [Release Branches] for more information.  Possible
    values are:

    | Branch                  | Directory   |
    | ------                  | ---------   |
    | `-CURRENT`              | `snapshots` |
    | `-STABLE`               | `snapshots` |
    | `-ALPHA1`, `-ALPHA2`, … | `snapshots` |
    | `-PRERELEASE`           | `snapshots` |
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

| Name         | Description                                                               |
| ----         | -----------                                                               |
| [`update`]   | Updates to the latest patch level (if applicable) and the latest packages |
| [`vagrant`]  | Vagrant-related configuration                                             |
| [`zeroconf`] | Enables zero-configuration networking                                     |
| [`ansible`]  | Installs python and CA Root certificates                                  |
| [`ports`]    | Installs the FreeBSD ports tree                                           |
| [`vmtools`]  | Virtual Machine-specific utilities                                        |
| [`cleanup`]  | Cleanup script                                                            |

### Handling `.iso` and `.box` files

Packer will automatically download the `.iso` image if it does not find
the right one under the `iso` directory.  Optionally, you can download
the `.iso` image and save it to the `iso` directory.

`.box` files will be created under the `builds` directory.

### Sample `Vagrantbox` file


```ruby
servers = [
  { name: 'www.local', cpus: 2, memory: 512 },
  { name: 'db.local', cpus: 1, memory: 1024 }
]

script = <<-SCRIPT
  sed -i '' "s/Vagrant/$(hostname -s)/g" /usr/local/etc/mDNSResponderServices.conf
  service mdnsresponderposix restart
SCRIPT

ansible_raw_arguments = []

Vagrant.require_version '>= 1.9.0'

Vagrant.configure(2) do |config|
  servers.each do |server|
    config.vm.define server[:name] do |box|
      box.vm.guest    = 'freebsd'
      box.vm.box      = 'FreeBSD-11.1-RELEASE-amd64'
      box.vm.hostname = server[:name]
      box.vm.network 'private_network', type: 'dhcp'
      box.vm.synced_folder '.', '/vagrant', type: 'nfs'
      box.vm.provider 'virtualbox' do |v|
        v.linked_clone           = true
        v.name, v.cpus, v.memory = server.values_at(:name, :cpus, :memory)
      end

      if server == servers.last
        box.vm.provision 'ansible' do |ansible|
          ansible.limit          = 'all'
          ansible.playbook       = 'site.yml'
          ansible.inventory_path = 'local'
          ansible.raw_arguments  = ansible_raw_arguments
        end
      else
        ansible_raw_arguments << private_key_path(server[:name])
      end
    end
  end

  config.vm.provision 'shell', inline: script
end

def private_key_path(server_name)
  provider = ENV['VAGRANT_DEFAULT_PROVIDER'] || 'virtualbox'
  vagrant_dotfile_path = ENV['VAGRANT_DOTFILE_PATH'] || '.vagrant'

  "--private-key=#{vagrant_dotfile_path}/machines/#{server_name}/" \
    "#{provider}/private_key"
end
```

TODO
====

- [ ] Fix rc.conf dir

[official FreeBSD]: https://app.vagrantup.com/freebsd
[Release Branches]: https://www.freebsd.org/doc/en/books/dev-model/release-branches.html
[Packer]: https://www.packer.io/docs/installation.html
[Vagrant]: https://www.vagrantup.com/downloads.html
[VirtualBox]: https://www.virtualbox.org/wiki/Downloads
[VMWare Fusion]: http://www.vmware.com/products/fusion/
[`ansible`]: https://github.com/jlduran/packer-FreeBSD/blob/master/scripts/ansible.sh
[`cleanup`]: https://github.com/jlduran/packer-FreeBSD/blob/master/scripts/cleanup.sh
[`ports`]: https://github.com/jlduran/packer-FreeBSD/blob/master/scripts/ports.sh
[`update`]: https://github.com/jlduran/packer-FreeBSD/blob/master/scripts/update.sh
[`vagrant`]: https://github.com/jlduran/packer-FreeBSD/blob/master/scripts/vagrant.sh
[`vmtools`]: https://github.com/jlduran/packer-FreeBSD/blob/master/scripts/vmtools.sh
[`zeroconf`]: https://github.com/jlduran/packer-FreeBSD/blob/master/scripts/zeroconf.sh
