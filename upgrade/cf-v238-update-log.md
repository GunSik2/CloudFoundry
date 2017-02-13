# bosh-lite cf-v238-update-log

### v238 to v252 
- Sequential update works well.
- For updting diego from v250 to v251, network configuration change is requried, because of duplication of subnet.
- The garden_runc is first applied on cf v247, even though cf v246 added the garden_run but the yaml did use garden_linux.
```
ver_cf=238; ver_etcd=57; ver_garden_linux=0.338.0; ver_garden_runc=; ver_diego=0.1476.0; ver_rootfs=1.16.0; ver_stemcell=3147
ver_cf=239; ver_etcd=60; ver_garden_linux=0.342.0; ver_garden_runc=; ver_diego=0.1480.0; ver_rootfs=1.18.0; ver_stemcell=3262.2
ver_cf=240; ver_etcd=63; ver_garden_linux=0.342.0; ver_garden_runc=; ver_diego=0.1481.0; ver_rootfs=1.21.0; ver_stemcell=3262.2
ver_cf=241; ver_etcd=66; ver_garden_linux=0.342.0; ver_garden_runc=; ver_diego=0.1483.0; ver_rootfs=1.27.0; ver_stemcell=3262.2
ver_cf=242; ver_etcd=67; ver_garden_linux=0.342.0; ver_garden_runc=; ver_diego=0.1485.0; ver_rootfs=1.29.0; ver_stemcell=3262.2
ver_cf=243; ver_etcd=67; ver_garden_linux=0.342.0; ver_garden_runc=; ver_diego=0.1485.0; ver_rootfs=1.29.0; ver_stemcell=3262.2
ver_cf=244; ver_etcd=70; ver_garden_linux=0.342.0; ver_garden_runc=; ver_diego=0.1486.0; ver_rootfs=1.33.0; ver_stemcell=3262.2
ver_cf=245; ver_etcd=73; ver_garden_linux=0.342.0; ver_garden_runc=; ver_diego=0.1487.0; ver_rootfs=1.35.0; ver_stemcell=3262.2
ver_cf=246; ver_etcd=78; ver_garden_linux=; ver_garden_runc=1.0.0; ver_diego=0.1487.0; ver_rootfs=1.38.0; ver_stemcell=3262.2  #garden_runc not applied in yaml
ver_cf=247; ver_etcd=85; ver_garden_linux=; ver_garden_runc=1.0.3; ver_diego=0.1489.0; ver_rootfs=1.39.0; ver_stemcell=3309    #
ver_cf=248; ver_etcd=86; ver_garden_linux=; ver_garden_runc=1.0.3; ver_diego=1.1.0; ver_rootfs=1.41.0; ver_stemcell=3312.6
ver_cf=249; ver_etcd=87; ver_garden_linux=; ver_garden_runc=1.0.4; ver_diego=1.2.0; ver_rootfs=1.41.0; ver_stemcell=3312.7
ver_cf=250; ver_etcd=87; ver_garden_linux=; ver_garden_runc=1.0.4; ver_diego=1.4.1; ver_rootfs=1.44.0; ver_stemcell=3312.12
ver_cf=251; ver_etcd=87; ver_garden_linux=; ver_garden_runc=1.1.1; ver_diego=1.5.3; ver_rootfs=1.45.0; ver_stemcell=3312.15
ver_cf=252; ver_etcd=90; ver_garden_linux=; ver_garden_runc=1.1.1; ver_diego=1.6.2; ver_rootfs=1.48.0; ver_stemcell=3312.17
```

