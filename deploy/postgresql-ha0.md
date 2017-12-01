# Postgres + PAF

[PAF](http://clusterlabs.github.io/)(PostgreSQL Automatic Failover) is High-Availibility for Postgres, based on Pacemaker and Corosync.

## Env
- Ubuntu 16.04
- hosts
```
172.19.3.10     portal_svc_db1
172.19.3.9      portal_svc_db2
172.19.3.8      portal_svc_dbvip
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
apt install pacemaker fence-agents net-tools pcs -y
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
- On all nodes: stop corosync & pacemaker.
```
systemctl disable corosync
systemctl disable pacemaker
systemctl stop pacemaker.service corosync.service
```

- On all nodes: set a password for cluster management tool pcsd, which uses the hacluster system user to work and communicate with other members of the cluster.
```
passwd hacluster

systemctl enable pcsd
systemctl start pcsd
```
- On all nodes: Authenticate each node to the other ones using the following command
```
$ pcs cluster auth portal_svc_db1 portal_svc_db2 -u hacluster
Password:
portal_svc_db1: Authorized
portal_svc_db2: Authorized
```

## Cluster createion
- pcs cli tool is able to create and start the whole cluster.
- On one of the node:
```
pcs cluster setup --name portal_svc_db portal_svc_db1 portal_svc_db2
```

## Reference
- http://clusterlabs.github.io/PAF/Quick_Start-Debian-9-crm.html
- https://hub.docker.com/r/pschiffe/pcs/
