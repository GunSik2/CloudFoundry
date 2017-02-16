# Isolation Segments

## Enable Isolation Segments
1. Assign Diego cells a placement_tags property in your Diego manifest
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
2. Create isolation segments in CCDB
```
curl "https://api.example.org/v3/isolation_segments" \
  -X POST \
  -H "Authorization: bearer 7h15154l0n64lph4num3r1c57r1n6" \
  -d '{
    "name": "my_segment"
  }'
```

## Managing Isolation Segments
- List Isolation Segments
```
curl "https://api.example.org/v3/isolation_segments" \
  -X GET \
  -H "Authorization: bearer 7h15154l0n64lph4num3r1c57r1n6"
```
- Retrieve an Isolation Segment
```
curl "https://api.example.org/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913" \
  -X GET \
  -H "Authorization: bearer 7h15154l0n64lph4num3r1c57r1n6"
```
- Renames the isolation segment
```
curl "https://api.example.org/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913" \
  -X PUT \
  -H "Authorization: bearer 7h15154l0n64lph4num3r1c57r1n6" \
  -d '{
    "name": "my_isolation_segment"
  }'
```
- Delete an Isolation Segment
```
curl "https://api.example.org/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913" \
  -X DELETE \
  -H "Authorization: bearer 7h15154l0n64lph4num3r1c57r1n6" \
```

## Manage Isolation Segment Relationships
- List Orgs for an Isolation Segment
```
curl "https://api.example.org/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913/relationships/organizations" \
  -X GET \
  -H "Authorization: bearer 7h15154l0n64lph4num3r1c57r1n6"
```
- List Spaces for an Isolation Segment
```
curl "https://api.example.org/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913/relationships/spaces" \
  -X GET \
  -H "Authorization: bearer 7h15154l0n64lph4num3r1c57r1n6"
```
- Add Orgs to an Isolation Segment: Adds two orgs to an isolation segment
```
curl "https://api.example.org/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913/relationships/organizations" \
  -X POST \
  -H "Authorization: bearer 7h15154l0n64lph4num3r1c57r1n6" \
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
curl "https://api.example.org/v3/isolation_segments/323f211e-fea3-4161-9bd1-615392327913/relationships/organizations" \
  -X DELETE \
  -H "Authorization: bearer 7h15154l0n64lph4num3r1c57r1n6" \
  -d '{
    "data": [
      { "guid":"45a66ed9-cb76-46c3-92dd-b29187b50bfb" },
      { "guid":"d0540a63-3bec-42ff-abd9-8a30328ba296" }
    ]
  }'
```
- Set a Default Isolation Segment for an Org
```
curl "https\://api.example.org/v2/organizations/45a66ed9-cb76-46c3-92dd-b29187b50bfb" \
  -X PUT \
  -H "Authorization: bearer 7h15154l0n64lph4num3r1c57r1n6" \
  -d '{ \
    "default_isolation_segment_guid":"323f211e-fea3-4161-9bd1-615392327913" \
  }'
```
- Add Spaces in an Isolation Segment
```
curl "https\://api.example.org/v2/spaces/68d54d31-9b3a-463b-ba94-e8e4c32edbac" \
  -X PUT \
  -H "Authorization: bearer 7h15154l0n64lph4num3r1c57r1n6" \
  -d '{ \
    "isolation_segment_guid":"323f211e-fea3-4161-9bd1-615392327913" \
  }'
```
- Remove Spaces in an Isolation Segment
```
curl "https\://api.example.org/v2/spaces/68d54d31-9b3a-463b-ba94-e8e4c32edbac" \
  -X PUT \
  -H "Authorization: bearer 7h15154l0n64lph4num3r1c57r1n6" \
  -d '{ \
    "isolation_segment_guid": "NULL" \
  }'
```

## Reference
- https://docs.cloudfoundry.org/adminguide/isolation-segments.html
