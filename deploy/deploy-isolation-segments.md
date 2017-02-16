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
cf curl "/v3/isolation_segments" -X GET
```
- Retrieve an Isolation Segment
```
cf curl "/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913" -X GET 
```
- Renames the isolation segment
```
cf curl "/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913" -X PUT -d '{"name": "my_isolation_segment"}'
```
- Delete an Isolation Segment
```
cf curl "/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913" -X DELETE 
```

## Manage Isolation Segment Relationships
- List Orgs for an Isolation Segment
```
cf curl "/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913/relationships/organizations" -X GET 
```
- List Spaces for an Isolation Segment
```
cf curl "/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913/relationships/spaces" -X GET 
```
- Add Orgs to an Isolation Segment: Adds two orgs to an isolation segment
```
cf curl "/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913/relationships/organizations" -X POST \
  -d '{
    "data": [
      { "guid":"45a66ed9-cb76-46c3-92dd-b29187b50bfb" },
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
cf curl "/v2/organizations/45a66ed9-cb76-46c3-92dd-b29187b50bfb" -X PUT \
  -d '{ "default_isolation_segment_guid":"323f211e-fea3-4161-9bd1-615392327913"}'
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
