#!/bin/bash

set -o -x

ver_cf=250
ver_etcd=89
ver_garden=1.0.4
ver_diego=1.4.1
ver_rootfs=1.44.0
ver_stemcell=3312.12

ver_ruby=2.3.0
ver_golang=1.6.1
ver_vagrant=1.9.1

domain=bosh-lite.com

homepath=~/bin/

function main() {
    cmd=$1

    if [ ! -f "env.sh" ]; then
        echo "env.sh file doesn't exist"
        echo "  Create env.sh file"
        echo "    export BOSH_AWS_ACCESS_KEY_ID=<KEY>"
        echo "    export BOSH_AWS_SECRET_ACCESS_KEY=<SECRET>"
        echo "    export BOSH_LITE_KEYPAIR=bosh-lite"
        echo "    export BOSH_LITE_NAME=bosh-lite"
        echo "    export BOSH_LITE_SECURITY_GROUP=bosh-lite"
        echo "    export BOSH_LITE_PRIVATE_KEY=~/.ssh/bosh-lite.pem"
        retrun 1
    fi

    . env.sh
    if [ "$cmd" = "install" ]; then
        install_all
    elif [ "$cmd" = "start" ]; then
        start_all
    elif [ "$cmd" = "stop" ]; then
        stop_bosh_lite
    elif [ "$cmd" = "clean" ]; then
        clean_all
    else
        echo "$0 [install | start | stop]"
        return 1
    fi
}

function clean_all() {
    rm -f go${ver_golang}.linux-amd64.tar.gz
    rm -f vagrant_${ver_vagrant}_x86_64.deb
    rm -rf bosh-lite
    rm -rf ~/workspace/cf-release
    rm -rf ~/workspace/diego-release
    rm -rf ~/.rvm
}

function install_all() {
    mkdir $homepath; cd $homepath

    sudo apt-get update
    install_package
    install_vagrant
    install_bosh_lite
    install_go
    install_ruby
    install_bosh_cli
    install_spiff
    install_cf_cli

    download_cf
    download_diego
}

function start_all() {
    . ~/.bash_profile

    start_bosh_lite
    echo "waiting for 30 seconds for running bosh-lite..."
    sleep 30
    set_bosh_target
    upload_stemcell

    make_cf_manifest
    make_diego_manifest

    echo "starting to deploy cf..."
    deploy_cf
    echo "starting to deploy diego..."
    deploy_diego
}

function set_alias() {
    pubadd=$1
    echo "alias bosh-ssh='bosh ssh --gateway_identity_file=$BOSH_LITE_PRIVATE_KEY --gateway_host=$pubadd --gateway_user=ubuntu --strict_host_key_checking=no"  >> ~/.bash_profile
}

function upload_stemcell() {
    bosh upload stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=${ver_stemcell}
}

function install_vagrant() {
    wget https://releases.hashicorp.com/vagrant/${ver_vagrant}/vagrant_${ver_vagrant}_x86_64.deb
    sudo dpkg -i vagrant_${ver_vagrant}_x86_64.deb

    vagrant plugin install vagrant-aws
}


function install_bosh_lite() {
    sudo apt-get install git -y
    git clone https://github.com/cloudfoundry/bosh-lite.git
}


function set_bosh_target() {
    cd bosh-lite
    boshtarget=$(vagrant ssh-config | grep HostName | cut -d " " -f 4)
    bosh target $boshtarget

    #set_hosts $boshtarget
    cd -
}

function set_hosts() {
    boshtarget=$1
    localadd=$(nslookup $boshtarget | grep "Address: " | cut -d " " -f 2)
    # aa="ec2-xxxxx.compute-1.amazonaws.com"; aa=${aa%%\.*\.com}; aa=${aa#ec2-}; echo ${aa//-/.}
    pubadd=${boshtarget%%\.*\.com}; pubadd=${pubadd#ec2-}; pubadd=${pubadd//-/.}

    if [ -f "/etc/hosts.org" ]; then
        sudo cp /etc/hosts.org /etc/hosts
    fi

    sudo cp /etc/hosts /etc/hosts.org
    sudo sh -c "echo $pubadd api.bosh-lite.com >> /etc/hosts"
    sudo sh -c "echo $localadd login.bosh-lite.com >> /etc/hosts"
    sudo sh -c "echo $localadd loggregator.bosh-lite.com >> /etc/hosts"
    #sudo sh -c "echo \"alias bosh-ssh='bosh ssh --gateway_identity_file=$BOSH_LITE_PRIVATE_KEY --gateway_host=$pubadd --gateway_user=ubuntu --strict_host_key_checking=no\"  >> ~/.bash_profile"
}

function start_bosh_lite() {
    . env.sh
    cd bosh-lite
    vagrant up --provider=aws

    cd -
}

function stop_bosh_lite() {
    cd bosh-lite
    vagrant destroy -f
    cd -
}

function install_package() {
    sudo apt-get update
    sudo apt-get install curl unzip git libmysqlclient-dev libpq-dev unzip make -y
}

function install_go() {
    wget https://storage.googleapis.com/golang/go${ver_golang}.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go${ver_golang}.linux-amd64.tar.gz
    echo 'export GOROOT=/usr/local/go' >> ~/.bash_profile
    echo 'export PATH=$PATH:$GOROOT/bin' >> ~/.bash_profile
}

function install_ruby() {
    \curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    \curl -sSL https://get.rvm.io | bash -s stable --ignore-dotfiles
    echo 'source ~/.rvm/scripts/rvm' >> ~/.bash_profile
    . ~/.bash_profile
    rvm install ruby-$ver_ruby
    rvm rubygems current
    gem install bundle --no-document
    gem install rake
}


function install_bosh_cli() {
    gem install bosh_cli --no-ri --no-rdoc
}

function download_stemcell() {
    wget https://s3.amazonaws.com/bosh-core-stemcells/warden/${stemcell_bosh_lite}.tgz
}

function upload_stemcell() {
    bosh upload stemcell ${stemcell_bosh_lite}.tgz
}

function download_cf() {
    mkdir ~/workspace; cd ~/workspace
    git clone https://github.com/cloudfoundry/cf-release
    cd ~/workspace/cf-release
    git checkout v$ver_cf
    cd $homepath
}

function install_spiff() {
    wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64.zip
    unzip spiff_linux_amd64.zip; rm -f spiff_linux_amd64.zip
    sudo mv spiff /usr/local/bin
}

function make_cf_manifest() {
    cd ~/workspace/cf-release
    ./scripts/generate-bosh-lite-dev-manifest 2>/dev/null
    ./scripts/generate-bosh-lite-dev-manifest
    cd $homepath
}

function deploy_cf() {
    cf_yml=bosh-lite/deployments/cf.yml

    cd ~/workspace/cf-release
    bosh -n upload release releases/cf-${ver_cf}.yml
    bosh deployment $cf_yml
    bosh -n deploy
    bosh vms
    cd $homepath
}

function deploy_cf_custom() {
    cd ~/workspace/cf-release
    ./scripts/update
    bosh -n create release --force #releases/cf-226.yml
    bosh -n upload release
    bosh -n deploy
    bosh vms
    cd $homepath
}

function install_cf_cli() {
    curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar xvz
    chmod +x cf
    sudo mv cf /usr/local/bin
}


function download_diego() {
    cd ~/workspace
    git clone https://github.com/cloudfoundry-incubator/diego-release
    cd diego-release
    git checkout v$ver_diego
    cd $homepath

}

function make_diego_manifest() {
    cd ~/workspace/diego-release
    ./scripts/generate-bosh-lite-manifests
    cd $homepath
}


function deploy_garden_runc() {
    cd ~/workspace/
    git clone https://github.com/cloudfoundry/garden-runc-release/
    cd garden-runc-release
    git checkout v$ver_garden
    bosh upload release releases/garden-runc/garden-runc-${ver_garden}.yml
}


function deploy_diego() {
    diego_yml=bosh-lite/deployments/diego.yml

    #bosh upload release \
    #     https://bosh.io/d/github.com/cloudfoundry-incubator/garden-runc-release?v=$ver_garden

    deploy_garden_runc

    bosh upload release \
         https://bosh.io/d/github.com/cloudfoundry-incubator/etcd-release?v=$ver_etcd
    bosh upload release \
         https://bosh.io/d/github.com/cloudfoundry/cflinuxfs2-rootfs-release?v=$ver_rootfs

    cd ~/workspace/diego-release
    bosh -n upload release releases/diego-${ver_diego}.yml
    bosh deployment $diego_yml
    bosh -n deploy
}

function replace_boship() {
    file=$1
    tmpfile=$(mktemp /tmp/bosh.XXX)

    sed -e "s/bosh-lite.com/${boship}/g" < $file > $tmpfile
    mv $tmpfile $file
}

function replace_domain() {
    file=$1
    tmpfile=$(mktemp /tmp/bosh.XXX)

    sed -e "s/bosh-lite.com/${domain}/g" < $file > $tmpfile
    mv $tmpfile $file
}

function test_docker() {
    cf enable-feature-flag diego_docker
    cf push docker --docker-image cloudfoundry/lattice-app
}

main $*
