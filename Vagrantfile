# -*- mode: ruby -*-
unless Vagrant.has_plugin?("vagrant-vbguest")
  raise 'You need to install "vagrant-vbguest" plugin in order to work with this machine!'
end

require 'yaml'

githubSecrets = YAML.load_file(File.join(File.dirname(__FILE__), 'secrets/github.yaml'))

Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"

  config.vm.provider "virtualbox" do |v|
    v.memory = 14336
    v.cpus = 6
  end

  config.vm.provision "file", source: "files/daemon.json",
                      destination: "/tmp/daemon.json"

  config.vm.provision "shell", path: "scripts/init.sh",
                      env: {
                          'GITHUB_CLIENTID' => githubSecrets['clientID'],
                          'GITHUB_SECRETID' => githubSecrets['secretID']
                      }


  config.vm.network "forwarded_port", guest: 8443, host: 8443
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 443
  config.vm.network "forwarded_port", guest: 80, host: 80

end
