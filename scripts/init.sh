#!/usr/bin/env bash

set -ex

temp_master_config_file='/tmp/master-config.yaml'

yum install -y epel-release > /dev/null 2>&1
yum update -y > /dev/null 2>&1
yum install -y python-pip python2-httpie.noarch wget docker git > /dev/null 2>&1

# We require to setup an insecure registry for some
# images installed by openshift
mv -vf /tmp/daemon.json /etc/docker/daemon.json

systemctl start docker
systemctl status docker
systemctl enable docker

yum install -y centos-release-openshift-origin
yum install -y origin-clients


git clone https://github.com/openshift-evangelists/oc-cluster-wrapper
echo 'PATH=$HOME/oc-cluster-wrapper:$PATH' >> $HOME/.bash_profile
echo 'export PATH' >> $HOME/.bash_profile
source .bash_profile

oc cluster up
