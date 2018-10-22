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

yum install -y centos-release-openshift-origin37
yum install -y origin-clients

pushd "${HOME}"

    git clone https://github.com/openshift-evangelists/oc-cluster-wrapper
    echo 'PATH=$HOME/oc-cluster-wrapper:$PATH' >> $HOME/.bash_profile
    echo 'export PATH' >> $HOME/.bash_profile
    source .bash_profile

    if [ "${DOMAIN_NAME}" == "localhost" ]; then
        oc cluster up
    else
        oc cluster up --public-hostname="${DOMAIN_NAME}"
    fi


    sleep 30s

    oc login -u system:admin

    oc create serviceaccount userroot

    oc adm policy add-scc-to-user anyuid -z useroot

    oc adm policy add-cluster-role-to-group admin system:authenticated

    oc cluster down

    sed --in-place='' "s/\${domainName}/${DOMAIN_NAME}/g" /tmp/master-config.yaml
    sed --in-place='' "s/\${clientID}/${GITHUB_CLIENTID}/g" /tmp/master-config.yaml
    sed --in-place='' "s/\${secretID}/${GITHUB_SECRETID}/g" /tmp/master-config.yaml
    sed --in-place='' "s/\${githubOrganization}/${GITHUB_ORGANIZATION}/g" /tmp/master-config.yaml

    mv -vf /tmp/master-config.yaml /var/lib/origin/openshift.local.config/master/
    htpasswd -b -c /var/lib/origin/openshift.local.config/master/htpasswords \
        serviceacc "${OPENSHIFT_SERVICE_ACCOUNT_PASSWORD}"

    oc cluster up --use-existing-config=true

    while ! http --check-status --verify=no GET https://localhost:8443/
    do
        echo '.'; sleep 5s
    done

    sleep 30s

    oc login -u serviceacc -p "${OPENSHIFT_SERVICE_ACCOUNT_PASSWORD}" --insecure-skip-tls-verify=true

    # Pet Projects Namespace
    oc new-project pet-projects --description="Pet Projects" --display-name="Projects"
    oc new-app 'https://github.com/ElderMael/discord-ts'
    oc adm policy add-role-to-user admin "${GITHUB_USERNAME}"

    # Tooling Namespace
    oc new-project tools --description="Tools that run on the server" --display-name="Tools"
    # oc process -f /tmp/oc_templates/vpn_secret.yaml | oc apply -f -
    oc adm policy add-role-to-user admin "${GITHUB_USERNAME}"
    oc new-app 'https://github.com/hwdsl2/docker-ipsec-vpn-server.git'



popd
