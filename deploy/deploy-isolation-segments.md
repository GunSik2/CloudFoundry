# Isolation Segments

## Enable Isolation Segments
- Assign Diego cells a placement_tags property in your Diego manifest
  - Isolation segment names must be unique across the entire system, and are not case-sensitive
```
$ cat diego.yml
- instances: 1
  name: cell_z2
  networks:
  - name: diego2
  properties:
    diego:
     rep:
       [...] 
          placement_tags:
          - my_segment
$ bosh deploy          
```
- Create isolation segments in CCDB
```
cf curl "/v3/isolation_segments" -X POST -d '{"name": "my_segment"}'
```

## Managing Isolation Segments
- List Isolation Segments
```
$ cf curl "/v3/isolation_segments" -X GET
{
   "pagination": {
      "total_results": 2,
      "total_pages": 1,
      "first": {
         "href": "https://api.v2.paasxpert.com/v3/isolation_segments?page=1&per_page=50"
      },
      "last": {
         "href": "https://api.v2.paasxpert.com/v3/isolation_segments?page=1&per_page=50"
      },
      "next": null,
      "previous": null
   },
   "resources": [
      {
         "guid": "933b4c58-120b-499a-b85d-4b6fc9e2903b",
         "name": "shared",
         "created_at": "2017-02-16T06:43:37Z",
         "updated_at": "2017-02-16T06:43:37Z",
         "links": {
            "self": {
               "href": "https://api.v2.paasxpert.com/v3/isolation_segments/933b4c58-120b-499a-b85d-4b6fc9e2903b"
            },
            "organizations": {
               "href": "https://api.v2.paasxpert.com/v3/isolation_segments/933b4c58-120b-499a-b85d-4b6fc9e2903b/organizations"
            },
            "spaces": {
               "href": "https://api.v2.paasxpert.com/v3/isolation_segments/933b4c58-120b-499a-b85d-4b6fc9e2903b/relationships/spaces"
            }
         }
      },
      {
         "guid": "5dd7843c-b36b-4eb4-a016-659478b2237f",
         "name": "my_segment",
         "created_at": "2017-02-16T08:11:06Z",
         "updated_at": "2017-02-16T08:11:06Z",
         "links": {
            "self": {
               "href": "https://api.v2.paasxpert.com/v3/isolation_segments/5dd7843c-b36b-4eb4-a016-659478b2237f"
            },
            "organizations": {
               "href": "https://api.v2.paasxpert.com/v3/isolation_segments/5dd7843c-b36b-4eb4-a016-659478b2237f/organizations"
            },
            "spaces": {
               "href": "https://api.v2.paasxpert.com/v3/isolation_segments/5dd7843c-b36b-4eb4-a016-659478b2237f/relationships/spaces"
            }
         }
      }
   ]
}
```
- Retrieve an Isolation Segment
```
$ cf curl "/v3/isolation_segments/5dd7843c-b36b-4eb4-a016-659478b2237f" -X GET 
{
   "guid": "5dd7843c-b36b-4eb4-a016-659478b2237f",
   "name": "my_segment",
   "created_at": "2017-02-16T08:11:06Z",
   "updated_at": "2017-02-16T08:11:06Z",
   "links": {
      "self": {
         "href": "https://api.v2.paasxpert.com/v3/isolation_segments/5dd7843c-b36b-4eb4-a016-659478b2237f"
      },
      "organizations": {
         "href": "https://api.v2.paasxpert.com/v3/isolation_segments/5dd7843c-b36b-4eb4-a016-659478b2237f/organizations"
      },
      "spaces": {
         "href": "https://api.v2.paasxpert.com/v3/isolation_segments/5dd7843c-b36b-4eb4-a016-659478b2237f/relationships/spaces"
      }
   }
}
```
- Renames the isolation segment
```
cf curl "/v3/isolation_segments/5dd7843c-b36b-4eb4-a016-659478b2237f" -X PUT -d '{"name": "my_isolation_segment"}'
```
- Delete an Isolation Segment
```
cf curl "/v3/isolation_segments/5dd7843c-b36b-4eb4-a016-659478b2237f" -X DELETE 
```

## Manage Isolation Segment Relationships
- List Orgs for an Isolation Segment
```
cf curl "/v3/isolation_segments/5dd7843c-b36b-4eb4-a016-659478b2237f/relationships/organizations" -X GET 
```
- List Spaces for an Isolation Segment
```
cf curl "/v3/isolation_segments/5dd7843c-b36b-4eb4-a016-659478b2237f/relationships/spaces" -X GET 
```
- Add Orgs to an Isolation Segment: Adds two orgs to an isolation segment
```
cf curl "/v3/isolation_segments/5dd7843c-b36b-4eb4-a016-659478b2237f/relationships/organizations" -X POST \
  -d '{
    "data": [
      { "guid":"09e922a4-f16b-41ab-a047-7ecc01072b97" },
      { "guid":"d0540a63-3bec-42ff-abd9-8a30328ba296" }
    ]
  }' 
```
- Remove Orgs from an Isolation Segment: Removes two orgs from an isolation segment
  - You cannot remove an org from an isolation segment if the isolation segment contains a space within that org or if it is the default isolation segment for that org
```
cf curl "/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913/relationships/organizations" -X DELETE \
  -d '{
    "data": [
      { "guid":"45a66ed9-cb76-46c3-92dd-b29187b50bfb" },
      { "guid":"d0540a63-3bec-42ff-abd9-8a30328ba296" }
    ]
  }'
```
- Set a Default Isolation Segment for an Org
```
cf curl "/v2/organizations/09e922a4-f16b-41ab-a047-7ecc01072b97" -X PUT \
  -d '{ "default_isolation_segment_guid":"5dd7843c-b36b-4eb4-a016-659478b2237f"}'
```
- Add Spaces in an Isolation Segment
```
cf curl "/v2/spaces/68d54d31-9b3a-463b-ba94-e8e4c32edbac" -X PUT \
  -d '{ "isolation_segment_guid":"323f211e-fea3-4161-9bd1-615392327913"}'
```
- Remove Spaces in an Isolation Segment
```
cf curl "/v2/spaces/68d54d31-9b3a-463b-ba94-e8e4c32edbac" -X PUT \
  -d '{ "isolation_segment_guid": "NULL" }'
```

## Reference
- https://docs.cloudfoundry.org/adminguide/isolation-segments.html
- https://github.com/cloudfoundry-community/cf-docs-contrib/wiki/Design-Documents
- https://github.com/cloudfoundry/capi-release/releases/tag/1.21.0
- https://docs.cloudfoundry.org/concepts/security.html
- http://v3-apidocs.cloudfoundry.org/version/3.0.0/index.html#isolation-segments
