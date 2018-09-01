# -*- mode: ruby -*-
Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"

  config.vm.provider "virtualbox" do |v|
    v.memory = 14336
    v.cpus = 6
  end

  config.vm.provision "file", source: "files/daemon.json",
                      destination: "/tmp/daemon.json"

  config.vm.provision "shell", path: "scripts/init.sh"


  config.vm.network "forwarded_port", guest: 8443, host: 8443
  config.vm.network "forwarded_port", guest: 443, host: 443
  config.vm.network "forwarded_port", guest: 80, host: 80

end
