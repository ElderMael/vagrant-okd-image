#!/usr/bin/env bash

set -ex

openshift_server_directory="/root/openshift-server"
openshift_server_binary_url="https://github.com/openshift/origin/releases/download/v3.10.0/openshift-origin-server-v3.10.0-dd10d17-linux-64bit.tar.gz"

yum install -y epel-release > /dev/null 2>&1
yum update -y > /dev/null 2>&1
yum install -y python-pip python2-httpie.noarch wget docker  > /dev/null 2>&1

# We require to setup an insecure registry for some
# images installed by openshift
mv -vf /tmp/daemon.json /etc/docker/daemon.json

systemctl start docker
systemctl status docker
systemctl enable docker

mkdir -p ${openshift_server_directory}

pushd "${openshift_server_directory}"
    wget -q -O openshift-server.tar.gz  "${openshift_server_binary_url}"
    tar xvzf openshift-server.tar.gz --strip-components 1
    rm openshift-server.tar.gz
    export PATH="$(pwd)":$PATH
    sudo ./oc cluster up
popd
