VAGRANTFILE_API_VERSION = "2"

path = "#{File.dirname(__FILE__)}"

require 'yaml'
require path + '/scripts/homestead.rb'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  Homestead.configure(config, YAML::load(File.read(path + '/Homestead.yaml')))
  config.vm.provision :shell, path: "scripts/bootstrap.sh"
  config.vm.network :forwarded_port, guest: 27017, host: 27018
end
