# -*- mode: ruby -*-
Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.provision "file", source: "files/daemon.json",
                      destination: "/tmp/daemon.json"

  config.vm.provision "shell", path: "scripts/init.sh"


  config.vm.network "forwarded_port", guest: 8443, host: 8443

end
