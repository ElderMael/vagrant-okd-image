#!/usr/bin/env bash

set -ex

yum install -y epel-release > /dev/null 2>&1
yum update -y > /dev/null 2>&1
yum install -y python-pip python2-httpie.noarch wget docker git emacs httpd-tools > /dev/null 2>&1

# We require to setup an insecure registry for some
# images installed by openshift
mv -vf /tmp/daemon.json /etc/docker/daemon.json

systemctl start docker
systemctl status docker
systemctl enable docker

yum install -y centos-release-openshift-origin311
yum install -y origin-clients

pushd "${HOME}"

    mkdir -p /root/openshift.local.clusterup/openshift-apiserver/

    sed --in-place='' "s/\${domainName}/${DOMAIN_NAME}/g" /tmp/master-config.yaml
    sed --in-place='' "s/\${clientID}/${GITHUB_CLIENTID}/g" /tmp/master-config.yaml
    sed --in-place='' "s/\${secretID}/${GITHUB_SECRETID}/g" /tmp/master-config.yaml
    sed --in-place='' "s/\${githubOrganization}/${GITHUB_ORGANIZATION}/g" /tmp/master-config.yaml

    mv -vf /tmp/master-config.yaml /root/openshift.local.clusterup/openshift-apiserver/

    mkdir -p /etc/origin/master/

    htpasswd -b -c /etc/origin/master/htpasswd \
        serviceacc "${OPENSHIFT_SERVICE_ACCOUNT_PASSWORD}"

    oc cluster up --public-hostname="${DOMAIN_NAME}"

    while ! http --check-status --verify=no GET https://localhost:8443/console
    do
        echo '.'; sleep 5s
    done

    sleep 120s

    oc login -u system:admin

#     # Pet Projects Namespace
#    oc new-project pet-projects --description="Pet Projects" --display-name="Projects"
#    oc new-app 'https://github.com/ElderMael/discord-ts'
#    oc adm policy add-role-to-user admin "${GITHUB_USERNAME}"
#
#    # Tooling Namespace
#    oc new-project tools --description="Tools that run on the server" --display-name="Tools"
#    oc adm policy add-role-to-user admin "${GITHUB_USERNAME}"

popd
