# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version '>= 2.2.5'

Vagrant.configure(2) do |config|
  config.vm.guest = :freebsd
end
