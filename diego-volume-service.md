Cloud Foundry Volume Services
========


## Objective
How to attach data services that have a filesystem-based interface to my app deployed in cloudfoundry?

## Concepts
To support volume service, CF add two new concepts:
- Volume Mounts on Service Brokers
- Volume Drivers on Diego Cells

## Enabling Volume Services
Volume Services are disabled in CF by default, several extra permissions must be requested by the Volume Service in order to issue volume mounts

### CF Deployment
- Cloud Foundry must be deployed with the **cc.volume_services_enabled** BOSH property set to **true**.
- Diego must be deployed with the **executor.volman.driver_paths** BOSH property set to include all directories on the Cell
- The appropriate Volume Driver must be colocated on the Cell.

### Service Catalog
- The service in the catalog must require the **volume_mount** permission.
- The service in the catalog must set **bindable** to **true**.

## Volume Drivers
- Support Volume Drivers written against the Docker v1.12 Volume Plugin specification
- Docker Volume Plugin Docs: https://docs.docker.com/engine/extend/plugins_volume/

### Deploying Volume Drivers
Drivers are deployed onto Diego Cells in one of two ways. Either they are deployed as colocated jobs, or they are deployed as job-specific add-ons.
- Co-Located Drivers
  - Diego Co-Location Docs: https://github.com/cloudfoundry/diego-release/blob/develop/docs/manifest-generation.md#experimental-volume-stub-file
- Drivers as Add-ons
  - BOSH Add-On Docs: http://bosh.io/docs/runtime-config.html#addons

## Example Volume Services
- Bosh-Lite / Local Volume Service
  - BOSH Release: https://github.com/cloudfoundry-incubator/local-volume-release
- EMC Isilon Service
  - Broker BOSH Release: https://github.com/EMC-Dojo/cf-persist-service-broker
  - Driver BOSH Release: https://github.com/EMC-Dojo/rexray-boshrelease
- Amazon EFS Service
  - BOSH Release: https://github.com/cloudfoundry-incubator/efs-volume-release
- CephFS Service
  - BOSH Release: https://github.com/cloudfoundry-incubator/cephfs-bosh-release
  
  
## Reference
- volume service: https://github.com/cloudfoundry-incubator/volman
