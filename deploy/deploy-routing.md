## CF TCP routing deployment

### Deploy tcp routing
- download routing
```
mkdir -p ~/workspace; cd ~/workspace
git clone https://github.com/cloudfoundry-incubator/routing-release
cd ~/workspace/routing-release
git checkout v0.143.0
```
- make_routing_manifest
```
cd ~/workspace/routing-release
./scripts/generate-bosh-lite-manifest
```
- deploy routing
```
cd ~/workspace/routing-release
bosh -n upload release releases/routing-0.143.0.yml
bosh deployment bosh-lite/deployments/routing-manifest.yml
bosh -n deploy
```
- update cf.yml
```
      cc:
        default_to_diego_backend: true
      routing_api:
        enabled: true
```
- update cf
```
bosh deployment cf.yml
bosh -n deploy
```

### test tcp-routing
```
domain=bosh-lite.com

cf router-groups
cf create-shared-domain tcp.$domain --router-group default-tcp


cf quota default
cf update-quota default --reserved-route-ports 2
cf quota default

mkdir -p test-php; cd test-php
echo "<?php phpinfo(); ?>" > index.php
cf delete -f -r tcp-php
cf push tcp-php -d tcp.$domain --random-route -b php_buildpack
appurl=$(cf apps | grep tcp-php | sed 's/\s\+/ /g' | cut -d' ' -f6)
cd -

port=$(echo $appurl | cut -d':' -f2)

# run the following command in bosh-lite:
# sudo iptables -A FORWARD -p tcp -d $tcp_router --dport $port -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT 
# sudo iptables -t nat -A PREROUTING -p tcp -i eth0 --dport $port -j DNAT --to-destination $tcp_router:$port
# curl $appurl
```

## Reference
- https://github.com/cloudfoundry-incubator/routing-release
- https://docs.cloudfoundry.org/adminguide/enabling-tcp-routing.html
