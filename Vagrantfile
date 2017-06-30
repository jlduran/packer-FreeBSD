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
      box.vm.guest = :freebsd
      box.vm.box = 'FreeBSD-11.0-RELEASE-amd64'
      box.vm.network :private_network, type: 'dhcp'
      box.vm.hostname = server[:name]
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
