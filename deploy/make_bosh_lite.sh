#!/bin/bash

#set -o -x

domain="bosh-lite.com"  
bosh_target=192.168.50.4

ver_cf=238
ver_etcd=57
ver_garden=0.342.0 #0.338.0
ver_diego=0.1476.0
ver_rootfs=1.16.0
ver_ruby=2.3.0
ver_golang=1.6.1
stemcell_bosh_lite=bosh-stemcell-3147-warden-boshlite-ubuntu-trusty-go_agent
homepath=~/bin/
dir_manifest="$homepath/manifest-v${ver_cf}"


function main() {
    cmd=$1

    if [ "$cmd" = "prepare" ]; then
        prepare
    elif [ "$cmd" = "deploy" ]; then
        deploy
    elif [ "$cmd" = "clean" ]; then
        clean_all
    else
        echo "$0 [prepare | deploy | clean]"
        return 1
    fi
}

function clean() {
    rm -f ${stemcell_bosh_lite}.tgz
    rm -f go${ver_golang}.linux-amd64.tar.gz
    rm -f vagrant_1.8.0_x86_64.deb
    rm -rf bosh-lite
    rm -rf ~/workspace/cf-release
    rm -rf ~/workspace/diego-release
    rm -rf ~/.rvm
}

function prepare() {
    mkdir $homepath; cd $homepath

    install_package
    install_bosh_lite
    install_go
    install_ruby
    install_bosh_cli
    install_spiff
    install_cf_cli

    download_stemcell
    download_cf
    download_diego

}

function deploy() {
    . ~/.bash_profile

    set_bosh_target
    upload_stemcell

    make_cf_manifest
    make_diego_manifest

    patch_manifest

    echo "starting to deploy cf..."
    deploy_cf
    echo "starting to deploy diego..."
    deploy_diego
}

function print_iptables() {
    print_iptables_cmd 80
    print_iptables_cmd 443
    print_iptables_cmd 4443
    print_iptables_cmd 2222
}

function print_iptables_cmd() {
    port=$1
    echo "sudo iptables -A FORWARD -p tcp -d 10.244.0.34 --dport $port -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT"
    echo "sudo iptables -t nat -A PREROUTING -p tcp -i eth2 --dport $port -j DNAT --to-destination 10.244.0.34:$port"
}


function patch_manifest() {
    mkdir -p $dir_manifest; cd $dir_manifest
    cp ~/workspace/cf-release/bosh-lite/deployments/cf.yml .
    cp ~/workspace/diego-release/bosh-lite/deployments/diego.yml .

    enable_default_diego
    replace_domain cf.yml
    replace_domain diego.yml
    cd $homepath
}

function set_bosh_target() {
    bosh target $bosh_target
}

function install_package() {
    sudo apt-get update
    sudo apt-get install curl unzip git libmysqlclient-dev libpq-dev unzip -y
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
    wget https://s3.amazonaws.com/bosh-warden-stemcells/${stemcell_bosh_lite}.tgz
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

function deploy_diego() {
    diego_yml=bosh-lite/deployments/diego.yml

    bosh upload release \
         https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release?v=$ver_garden
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
    tmpfile=$(mktemp /tmp/manifest.XXX)

    sed -e "s/bosh-lite.com/${domain}/g" < $file > $tmpfile
    mv $tmpfile $file
}

function enable_default_diego() {
    file=cf.yml
    tmpfile=$(mktemp /tmp/manifest.XXX)

    sed -e "s/default_to_diego_backend: false/default_to_diego_backend: true/g" < $file > $tmpfile
    mv $tmpfile $file
}

function enable_routing_api() {
    file=cf.yml
    tmpfile=$(mktemp /tmp/manifest.XXX)

    sed -e '/routing_api/{ N; s/enabled: null/enabled: true/ }' < $file > $tmpfile
    mv $tmpfile $file
}

function test_docker() {
    cf enable-feature-flag diego_docker
    cf push docker --docker-image cloudfoundry/lattice-app
}

main $*
