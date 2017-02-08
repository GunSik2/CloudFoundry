## bosh-lite version compatilibity

In general, the compatible versions are specified in the release notes of cf and diego.
However, some old versions are not working correctly, because the bosh-lite (os) image itself is updated.

Here examples are describled.

### cf v238 with bosh-lite
- recommended versions in release notes
```
ver_cf=238
ver_etcd=57
ver_garden=0.338.0
ver_diego=0.1476.0
ver_rootfs=1.16.0
ver_stemcell=3147
```
- the bosh-lite version  (2017.02.08)
```
$ vagrant box list
cloudfoundry/bosh-lite (aws, 9000.137.0)
```

- error when deploy app in diego
```
{"timestamp":"1486087317.066910982","source":"garden-linux","message":"garden-linux.failed-to-parse-pool-state","log_level":2,"data":{"error":"openning state file: open /var/vcap/data/garden/port_pool.json: no such file or directory"}}
{"timestamp":"1486026583.906243801","source":"garden-linux","message":"garden-linux.loop-mounter.mount-file.mounting","log_level":2,"data":{"destPath":"/var/vcap/data/garden/aufs_graph/aufs/diff/f210abf1366f54c4872ee6318f94a7891d350aeab93e10437b4edbadaf43fe10","error":"exit status 32","filePath":"/var/vcap/data/garden/aufs_graph/backing_stores/f210abf1366f54c4872ee6318f94a7891d350aeab93e10437b4edbadaf43fe10","output":"mount: wrong fs type, bad option, bad superblock on /dev/loop6,\n       missing codepage or helper program, or other error\n       In some cases useful info is found in syslog - try\n       dmesg | tail  or so\n\n","session":"2.31"}}
{"timestamp":"1486026583.906821489","source":"garden-linux","message":"garden-linux.pool.acquire.provide-rootfs-failed","log_level":2,"data":{"error":"mounting file: mounting file: exit status 32","handle":"235d7b2f-2695-494a-b5e3-a9a3bf503eb4-0dbacbef6edd4d66971b348a6749f6dd","id":"7r2iiuvcpub","session":"8.49"}}
{"timestamp":"1486026583.907184362","source":"garden-linux","message":"garden-linux.garden-server.create.failed","log_level":2,"data":{"error":"mounting file: mounting file: exit status 32","request":{"Handle":"235d7b2f-2695-494a-b5e3-a9a3bf503eb4-0dbacbef6edd4d66971b348a6749f6dd","GraceTime":0,"RootFSPath":"/var/vcap/packages/cflinuxfs2/rootfs","BindMounts":[{"src_path":"/var/vcap/data/executor_cache/63ea7f2639ccaee90c1eb81aa5dbe0bc-1486024083980036103-1.d","dst_path":"/tmp/docker_app_lifecycle"}],"Network":"","Privileged":true,"Limits":{"bandwidth_limits":{},"cpu_limits":{},"disk_limits":{"inode_hard":200000,"byte_hard":6442450944,"scope":1},"memory_limits":{"limit_in_bytes":1073741824}}},"session":"11.3238"}}
{"timestamp":"1486026583.918168306","source":"garden-linux","message":"garden-linux.garden-server.destroy.failed","log_level":2,"data":{"error":"unknown handle: 235d7b2f-2695-494a-b5e3-a9a3bf503eb4-0dbacbef6edd4d66971b348a6749f6dd","handle":"235d7b2f-2695-494a-b5e3-a9a3bf503eb4-0dbacbef6edd4d66971b348a6749f6dd","session":"11.3239"}}
```

- resolution 
  - update stemcell version : 3147 to 3262.2 ==> same error
  - udpate stemcell version : 3262.2 to 3312.12 ==> same error
  - update garden-linux version : 0.338.0 to 0.342.0 (final latest) ==> success
  
- conclusion
  - bosh-lite 환경에서 garden-linux 는 vagrant box image 를 기반으로 하며 버전 호환성 필요

## reference
- garden-linux & vagrant colerelation: https://github.com/cloudfoundry-attic/garden-linux/issues/53
