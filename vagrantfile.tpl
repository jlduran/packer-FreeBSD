# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version '>= 1.9.0'

Vagrant.configure(2) do |config|
  config.vm.guest = :freebsd
  config.vm.network :private_network, type: 'dhcp'
  config.vm.synced_folder '.', '/vagrant', type: 'nfs'
end
