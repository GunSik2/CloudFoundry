## CF TCP routing deployment

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


## Reference
- https://github.com/cloudfoundry-incubator/routing-release
