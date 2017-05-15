## docker-boshrelease

## Deployment
- bosh release upload
```
git clone https://github.com/cf-platform-eng/docker-boshrelease.git
cd docker-boshrelease

bosh upload release releases/docker/docker-28.0.2.yml
```
- configure
```
vi samples/docker-swarm-broker-openstack.yml
# config following items
deployment_name
director_uuid
elastic_ip
root_domain

properties.nats.user
properties.nats.password
properties.nats.machines

properties.cf.admin_username
properties.cf.admin_password

properties.broker.username
properties.broker.password
```
- deploy
```
bosh deployment samples/docker-broker-aws-deploy.yml
bosh deploy
```
- enable broker
  - BROKER_NAME = properties.broker.name
  - BROKER_USER = properties.broker.username
  - BROKER_PASS = properties.broker.password
  - BROKER_HOST = properties.broker.host
```
cf create-service-broker BROKER_NAME BROKER_USER BROKER_PASS https://BROKER_HOST
ex) cf create-service-broker cf-containers-broker containers containers http://10.104.2.10
```
- enable service
```
# show all service plan and access
cf service-access

# enable all service plan
cf enable-service-access SERVICE
ex) cf enable-service-access postgresql93

# enalbe specific service plan
cf enable-service-access SERVICE -p PLAN -o ORG

# enalbe all services and plans
while read p __; do
    cf enable-service-access "$p";
done < <(cf service-access | awk '/orgs/{y=1;next}y && NF' | sort | uniq)
```
- create service instance
```
cf create-service SERVICE PLAN SERVICE_INSTANCE_NAME
```
- deploy app & bind it
```
cf bind-service APP_INSTAANCE_NAME SERVICE_INSTANCE_NAME
```


## Reference
- [Managing Stateful Docker Containers with Cloud Foundry BOSH](https://blog.pivotal.io/pivotal-cloud-foundry/products/managing-stateful-docker-containers-with-cloud-foundry-bosh)
- [Docker Service Broker for Cloud Foundry](https://blog.pivotal.io/pivotal-cloud-foundry/products/docker-service-broker-for-cloud-foundry)
- [cloud.gov Deploying the Docker broker](https://cloud.gov/docs/ops/deploying-the-docker-broker/)
- [cloud.gov Docker-broker manifest][(https://github.com/18F/cg-manifests)
- [Git: Containers Service Broker for Cloud Foundry](https://github.com/cloudfoundry-community/cf-containers-broker)
- [Git: Bosh release for Docker](https://github.com/cloudfoundry-community/docker-boshrelease)
- [Git: Kubernetes Service Broker](https://github.com/kubernetes-incubator/service-catalog)
- HOW-TO How to use OpenStack Cinder with Docker Swarm clusters [1](http://superuser.openstack.org/articles/how-to-use-openstack-cinder-for-docker/) [2](http://superuser.openstack.org/articles/how-to-use-cinder-with-swarm/)
