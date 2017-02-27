#!/bin/bash


ver_mysql=34
dir_workspace=~/workspace
dir_mysql=$dir_workspace/cf-mysql-release

function main() {
    service=$1
    if [ "$service" == "mysql" ]; then
        deploy_mysql
    else
        echo "$0 [service name]"
        echo "service name: mysql"
    fi
}

function deploy_mysql() {
    prepare_mysql
    prepare_mysql_config
    deploy_mysql
}


function prepare_mysql() {
    cd $dir_workspace
    git clone https://github.com/cloudfoundry/cf-mysql-release.git
    cd ${dir_mysql}
    git checkout v$ver_mysql
    bosh upload release releases/cf-mysql/cf-mysql-${ver_mysql}.yml
}

function prepare_mysql_config() {
    cd ${dir_mysql}
    scripts/generate-bosh-lite-manifest
    #./update
}

function deploy_mysql() {
    cd ${dir_mysql}
    bosh deployment cf-mysql.yml
    bosh deploy
}


main $*
