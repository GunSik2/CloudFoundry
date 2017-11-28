# PostgreSQL + PGPool

## Install PostgreSQL Master/Slave
- Install
```
sudo apt update
sudo apt install postgresql-9.5-pgpool2
```
- Check
```
dpkg -L postgresql-9.5-pgpool2
dpkg -L postgresql-9.5
```
- Config
```
sudo su - postgres
psql
# \password postgres
Enter new password:
Enter it again:

# \conninfo
You are connected to database "postgres" as user "postgres" via socket in "/var/run/postgresql" at port "5432"
```

## Configure Master Server
- /etc/postgresql/9.5/main/postgresql.conf
```
listen_addresses = '*'
#----------------------------
# WRITE AHEAD LOG
#---------------------------
wal_level = hot_standby
synchronous_commit = local
archive_mode = on
archive_command = 'cp %p /var/lib/postgresql/9.5/main/archive/%f'

#------------------------------------------------------------------------------
# REPLICATION
#------------------------------------------------------------------------------
max_wal_senders = 2
wal_keep_segments = 10
synchronous_standby_names = 'pgslave001'
```
-  archive directory 생성
```
sudo mkdir -p /var/lib/postgresql/9.5/main/archive/
sudo chmod 700 /var/lib/postgresql/9.5/main/archive/
sudo chown -R postgres:postgres /var/lib/postgresql/9.5/main/archive/
```
- /etc/postgresql/9.5/main/pg_hba.conf
```
# localhost
host    replication     postgres        127.0.0.1/32            md5
# master ip address
host    replication     postgres        172.17.3.9/32           md5
# slave ip address
host    replication     postgres        172.17.3.12/32          md5
```

- Resetart
```
sudo systemctl restart postgresql
```

- Create replica user
```
sudo su - postgres
psql
psql (9.5.10)
Type "help" for help.

# CREATE USER replica REPLICATION LOGIN ENCRYPTED PASSWORD 'koscom!234';
CREATE ROLE
# \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 replica   | Replication                                                | {}
```

## Configure Slave Server

## Reference
- [Google: Pgpool cluster](https://www.google.co.kr/search?q=pgtool+cluster&oq=pgtool+cluster&aqs=chrome..69i57j0l5.8079j0j7&sourceid=chrome&ie=UTF-8)
- https://www.sraoss.co.jp/event_seminar/2016/pgpool-II-3.5.pdf
- http://www.pgpool.net/docs/pgpool-II-3.7.0/doc/en/html/example-configs.html
- hhttps://www.devmanuals.net/install/ubuntu/ubuntu-16-04-LTS-Xenial-Xerus/how-to-install-postgresql-9.5-pgpool2.html
- https://www.howtoforge.com/tutorial/how-to-set-up-master-slave-replication-for-postgresql-96-on-ubuntu-1604/
