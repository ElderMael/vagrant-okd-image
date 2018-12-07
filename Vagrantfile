# -*- mode: ruby -*-

require 'yaml'

secrets = YAML.load_file(File.join(File.dirname(__FILE__), 'secrets/secrets.yaml'))

Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"

  config.vm.provider "virtualbox" do |v|
    v.memory = 14336
    v.cpus = 6
  end

  # config.vm.synced_folder "openshift_config/", "/home/vagrant/openshift.local.clusterup/"

  config.vm.provision "file", source: "files/daemon.json",
                      destination: "/tmp/daemon.json"

  config.vm.provision "file", source: "files/master-config.yaml",
                      destination: "/tmp/master-config.yaml"

  config.vm.provision "file", source: "files/oc_templates/",
                      destination: "/tmp/oc_templates"

  config.vm.provision "shell", path: "scripts/init.sh", env: secrets


  config.vm.network "forwarded_port", guest: 80, host: 80
  config.vm.network "forwarded_port", guest: 443, host: 443
  config.vm.network "forwarded_port", guest: 500, host: 500
  config.vm.network "forwarded_port", guest: 4500, host: 4500
  config.vm.network "forwarded_port", guest: 8443, host: 8443
  config.vm.network "forwarded_port", guest: 8080, host: 8080

end
