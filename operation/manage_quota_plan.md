## Manage quota

list Quota plans
```
cf quotas
```

- quota plans using manifest
``` yaml
    quota_definitions:
      gold:
        memory_limit: 10240
        non_basic_services_allowed: true
        total_routes: 1000
        total_services: 100
      silver:
        memory_limit: 4096
        non_basic_services_allowed: true
        total_routes: 20
        total_services: 20
      trial:
        memory_limit: 2048
        non_basic_services_allowed: true
        total_routes: 10
        total_services: 10
      default:
        memory_limit: 2048
        non_basic_services_allowed: true
        total_routes: 10
        total_services: 10
```

- quota plans using  cf create-quota
``` bash
cf create-quota  QUOTA [-m MEMORY] [-r ROUTES] [-s SERVICE_INSTANCES] [--allow-paid-service-plans]

cf create-quota trial -m 2048M -r 10 -s 10 --allow-paid-service-plans
```

- modifying a Quota Plan 
```
cf update-quota QUOTA [-m MEMORY] [-n NEW_NAME] [-r ROUTES] [-s SERVICE_INSTANCES] [--allow-paid-service-plans | --disallow-paid-service-plans]

cf update-quota small -m 4096M -n medium -r 20 -s 20 --allow-paid-service-plans
```
