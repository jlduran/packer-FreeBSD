# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version '>= 1.6.0'

Vagrant.configure(2) do |config|
  config.vm.guest = :freebsd
  config.vm.synced_folder '.', '/vagrant', type: 'nfs'

  config.vm.define 'hostname' do |hostname|
    hostname.vm.box = 'FreeBSD-11.2-RELEASE-amd64'
    hostname.vm.network :private_network, type: 'dhcp'
  end
end
