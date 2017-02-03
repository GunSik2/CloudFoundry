# Manage org quota

query quota plan of an org
```
function get_org_quota_plan {
    ORGANIZATION=$1
    ORG_GUID=$(CF_TRACE=true cf org  $ORGANIZATION | grep "guid" | head -n 1 | cut -d ":" -f 2 | cut -d "\"" -f 2)
    QUOTA_GUID=$(cf curl /v2/organizations/$ORG_GUID -X 'GET' | grep quota_definition_guid | head -n 1 | cut -d ":" -f 2 | cut -d "\"" -f 2)
    cf curl /v2/quota_definitions -X 'GET' | grep $QUOTA_GUID -B 1 -A 14 | grep entity -A10
}
```

set quota to an org
```
cf set-quota ORG_NAME QUOTA_PLAN
``` 
