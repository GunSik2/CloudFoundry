# Postgres + PAF

[PAF](http://clusterlabs.github.io/)(PostgreSQL Automatic Failover) is High-Availibility for Postgres, based on Pacemaker and Corosync.

## Env
- Ubuntu 16.04
- hosts
```
172.19.3.10     portal_svc_db1 postgres1
172.19.3.9      portal_svc_db2 postgres2
172.19.3.8      portal_svc_dbvip postgres-vip
```

## PostgreSQL and Cluster stack installation
- postgres-9.6
```
apt install software-properties-common
add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt update
apt install postgresql-9.6
```
- paf 
```
wget 'https://github.com/ClusterLabs/PAF/releases/download/v2.2.0/resource-agents-paf_2.2.0-2_all.deb'
dpkg -i resource-agents-paf_2.2.0-2_all.deb
apt -f install
```
- paf stats_temp_directory
```
cat <<EOF > /etc/tmpfiles.d/postgresql-part.conf
# Directory for PostgreSQL temp stat files
d /var/run/postgresql/9.6-main.pg_stat_tmp 0700 postgres postgres - -
EOF

systemd-tmpfiles --create /etc/tmpfiles.d/postgresql-part.conf
```
- pacemaker 
```
# apt install pacemaker fence-agents net-tools pcs -y
apt install docker.io
```

## PostgreSQL setup
- On all nodes
```
su - postgres

cd /etc/postgresql/9.6/main/

cat <<EOP >> postgresql.conf
listen_addresses = '*'
wal_level = replica
max_wal_senders = 10
hot_standby = on
hot_standby_feedback = on
logging_collector = on
EOP

cat <<EOP >> pg_hba.conf
# forbid self-replication
host replication postgres 172.19.3.8/32 reject
host replication postgres $(hostname -s) reject

# allow any standby connection
host replication postgres 0.0.0.0/0 trust
EOP

cat <<EOP > recovery.conf.pcmk
standby_mode = on
primary_conninfo = 'host=172.19.3.8 application_name=$(hostname -s)'
recovery_target_timeline = 'latest'
EOP

exit
```

- On srv1
```
systemctl restart postgresql@9.6-main

ip addr add 172.19.3.8/24 dev ens:0
```

- On standby (srv2, srv3, etc)
```
systemctl stop postgresql@9.6-main
su - postgres

rm -rf 9.6/main/
pg_basebackup -h portal_svc_dbvip -D ~postgres/9.6/main/ -X stream -P

cp /etc/postgresql/9.6/main/recovery.conf.pcmk ~postgres/9.6/main/recovery.conf

exit

systemctl start postgresql@9.6-main
```

- On all nodes: stop all services, as Pacemaker will take care of starting/stopping everything.
```
systemctl stop postgresql@9.6-main
systemctl disable postgresql@9.6-main
echo disabled > /etc/postgresql/9.6/main/start.conf
```

- On srv1 : remove the master ip
```
ip addr del 172.19.3.8/24 dev ens3:0
```

## Cluster pre-requisites
- On all nodes: run packemaker corosync & pacemaker.
```
docker run -d --privileged --net=host -p 2224:2224 -v /sys/fs/cgroup:/sys/fs/cgroup -v /etc/localtime:/etc/localtime:ro -v /run/docker.sock:/run/docker.sock -v /usr/bin/docker:/usr/bin/docker:ro --name pcs pschiffe/pcs
```

- On all nodes: 
  - set a password for cluster management tool pcsd, which uses the hacluster system user to work and communicate with other members of the cluster.
  - Authenticate each node to the other ones using the following command
```
docker exec -it pcs bash
passwd hacluster
pcs cluster auth postgres1 postgres2 -u hacluster
```

## Cluster createion
- pcs cli tool is able to create and start the whole cluster.
- On one of the node:
```
$ docker exec -it pcs bash

# pcs cluster setup --name postgres postgres1 postgres2
# pcs cluster start --all
# pcs cluster enable --all
# crm_mon -n1D
Node postgres1: online
Node postgres2: online
```
- On one of the node, set virtual ip
```
pcs resource create virtual-ip IPaddr2 ip=172.19.3.8 --group postgres
pcs status
```
- cluster config
```
pcs resource defaults migration-threshold=5
pcs resource defaults resource-stickiness=10
```

## Cluster resources
The pgsqld defines the properties of a PostgreSQL instance: where it is located, where are its binaries, its configuration files, how to montor it, and so on.

The pgsql-ha resource controls all the PostgreSQL instances pgsqld in your cluster, decides where the primary is promoted and where the standbys are started.

The pgsql-master-ip resource controls the pgsql-vip IP address. It is started on the node hosting the PostgreSQL master resource.


- create CIB
```
pcs cluster cib cluster1.xml
```
- pgsqld
```
pcs -f cluster1.xml resource create pgsqld ocf:heartbeat:pgsqlms \
    bindir=/usr/pgsql-9.6/bin pgdata=/var/lib/pgsql/9.6/data     \
    op start timeout=60s                                         \
    op stop timeout=60s                                          \
    op promote timeout=30s                                       \
    op demote timeout=120s                                       \
    op monitor interval=15s timeout=10s role="Master"            \
    op monitor interval=16s timeout=10s role="Slave"             \
    op notify timeout=60s

pcs -f cluster1.xml resource master pgsql-ha pgsqld notify=true

pcs resource create [docker-master] ocf:heartbeat:docker image=[docker-master] reuse=1 run_opts='[-p 8080]' --group [master-group]    
```

## Reference
- http://clusterlabs.github.io/PAF/Quick_Start-Debian-9-crm.html
- https://hub.docker.com/r/pschiffe/pcs/
- https://www.digitalocean.com/community/tutorials/how-to-set-up-an-apache-active-passive-cluster-using-pacemaker-on-centos-7
