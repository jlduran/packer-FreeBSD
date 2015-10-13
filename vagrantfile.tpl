# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version '>= 1.6.0'

Vagrant.configure(2) do |config|
  config.vm.guest = :freebsd
  config.vm.synced_folder '.', '/vagrant', type: 'nfs'

  # config.ssh.shell = '/bin/tcsh'

  config.vm.define 'hostname' do |hostname|
    hostname.vm.box = 'FreeBSD-10.3-RELEASE-amd64'
    # hostname.vm.box_url = './builds/FreeBSD-10.3-RELEASE-amd64.box'
    hostname.vm.network :private_network, ip: '10.10.10.10'
  end
end
