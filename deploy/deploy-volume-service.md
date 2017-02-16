# Diego volume service Deployment

## Script
```
homepath=~/bin/
ver_nfs=0.1.4


function git_clone() {
    mkdir -p ~/workspace; cd ~/workspace
    git clone https://github.com/cloudfoundry-incubator/nfs-volume-release
    cd nfs-volume-release
    git checkout v$ver_nfs

    cd $homepath
}


function upload_release() {
    cd ~/workspace/nfs-volume-release
    bosh upload release releases/nfs-volume/nfs-volume-$ver_nfs.yml
}



function enable_cf_volume_service() {
    # properties: cc: volume_services_enabled
    echo
}

function enable_diego_volume_driver() {
    # bosh add-ons with filtering

    config=/tmp/runtime-config.yml
    diegoyml=/tmp/diego.yml
    write_runtime_config $config
    bosh update runtime-config $config
    bosh download manifest cf-warden-diego $diegoyml
    bosh -d $diegoyml deploy
}

function write_runtime_config() {
    config=$1
    cat > $config <<EOF
---
releases:
- name: nfs-volume
  version: $ver_nfs
addons:
- name: voldrivers
  include:
    deployments:
    - cf-warden-diego
    jobs:
    - name: rep
      release: diego
  jobs:
  - name: nfsv3driver
    release: nfs-volume
    properties: {}
EOF
}

```

## Reference
- https://docs.cloudfoundry.org/adminguide/deploy-vol-services.html
- https://github.com/cloudfoundry-incubator/nfs-volume-release
