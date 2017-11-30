# PostgreSQL + PGPool

## Env
- Master (172.17.3.9) accepts connections from the client with read and write permissions
- Slave (172.17.3.12) the standby server runs a copy of the data from the master server with read-only permission.

![](https://user-images.githubusercontent.com/11453229/33374601-311f6c12-d54a-11e7-99d2-6983a6ee4e7f.png)


## Install PostgreSQL Master/Slave
- Install
```
sudo apt update
sudo apt install postgresql-9.5
```
- Check
```
dpkg -L postgresql-9.5
#dpkg -L postgresql-9.5-pgpool2
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

## Master Server
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
host    all             replica        172.17.3.0/24           md5
# localhost
host    replication     replica        127.0.0.1/32            md5
# master ip address
host    replication     replica        172.17.3.9/32           md5
# slave ip address
host    replication     replica        172.17.3.12/32          md5
```

- /var/lib/postgresql/9.5/main/recovery.conf
```
standby_mode = 'on'
primary_conninfo = 'host=172.17.3.12 port=5432 user=replica password=aqwe123@ application_name=pgslave001'
restore_command = 'cp /var/lib/postgresql/9.5/main/archive/%f %p'
trigger_file = '/tmp/postgresql.trigger.5432'
```

- Resetart
```
sudo systemctl restart postgresql
```

- Check replica user
```
$ sudo su - postgres
$ psql
# CREATE USER replica REPLICATION LOGIN ENCRYPTED PASSWORD 'aqwe123@';
# \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 replica   | Replication                                                | {}
```

## Slave Server

- /etc/postgresql/9.5/main/postgresql.conf
```
listen_addresses = '*'
#----------------------------
# WRITE AHEAD LOG
#---------------------------
wal_level = hot_standby
synchronous_commit = local

#------------------------------------------------------------------------------
# REPLICATION
#------------------------------------------------------------------------------
max_wal_senders = 2
wal_keep_segments = 10
synchronous_standby_names = 'pgslave001'
hot_standby = on
```
- /etc/postgresql/9.5/main/pg_hba.conf
```
host    all             replica        172.17.3.0/24           md5
# localhost
host    replication     replica        127.0.0.1/32            md5
# master ip address
host    replication     replica        172.17.3.9/32           md5
# slave ip address
host    replication     replica        172.17.3.12/32          md5
```

- Master postgreSQL data 를 Salve 로 복제 
```
$ sudo su - postgres
$ cd 9.5
$ mv main main-backup
$ mkdir main; chmod 700 main
$ pg_basebackup -h 172.17.3.9 -U postgres -D /var/lib/postgresql/9.5/main -P --xlog
```

- Slave 설정
```
$ vi /var/lib/postgresql/9.5/main/recovery.conf
standby_mode = 'on'
primary_conninfo = 'host=172.17.3.9 port=5432 user=replica password=aqwe123@ application_name=pgslave001'
restore_command = 'cp /var/lib/postgresql/9.5/main/archive/%f %p'
trigger_file = '/tmp/postgresql.trigger.5432'

$ chmod 600 /var/lib/postgresql/9.5/main/recovery.conf
$ logout

$ sudo systemctl start postgresql
$ tail -f /var/log/postgresql/postgresql-9.5-main.log
2017-11-29 21:00:07 KST [11242-3] LOG:  redo starts at 0/13000028
2017-11-29 21:00:07 KST [11242-4] LOG:  consistent recovery state reached at 0/130000F8
2017-11-29 21:00:07 KST [11241-1] LOG:  database system is ready to accept read only connections
cp: cannot stat '/var/lib/postgresql/9.5/main/archive/000000010000000000000014': No such file or directory
2017-11-29 21:00:08 KST [11250-1] LOG:  started streaming WAL from primary at 0/14000000 on timeline 1
2017-11-29 21:00:08 KST [11251-1] [unknown]@[unknown] LOG:  incomplete startup packet

$ netstat -plntu
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp        0      0 172.17.3.12:5432        0.0.0.0:*               LISTEN      -
tcp6       0      0 :::22                   :::*                    LISTEN      -
```


## Testing
- @Master: Check cluster status
```
$ su - postgres
$ psql -c "select application_name, state, sync_priority, sync_state from pg_stat_replication;"
 application_name |   state   | sync_priority | sync_state
------------------+-----------+---------------+------------
 pgslave001       | streaming |             1 | sync

$ psql -c "select application_name, state, sync_priority, sync_state from pg_stat_replication;"
 application_name |   state   | sync_priority | sync_state
------------------+-----------+---------------+------------
 pgslave001       | streaming |             1 | sync
```

- @Master: Create table 
```
su - postgres
psql
CREATE TABLE replica_test (hakase varchar(100));
INSERT INTO replica_test VALUES ('howtoforge.com');
INSERT INTO replica_test VALUES ('This is from Master');
INSERT INTO replica_test VALUES ('pg replication by hakase-labs');
```
- @Slave
```
$ su - postgres
$ psql
# select * from replica_test;
# INSERT INTO replica_test VALUES ('this is SLAVE');
ERROR:  cannot execute INSERT in a read-only transaction
```

## Manual Failover 
### kill master process
- process kill
```
killall postgres
```
- Slave : log
```
$ tail -f /var/log/postgresql/postgresql-9.5-main.log
2017-11-30 19:09:51 KST [12942-2] FATAL:  could not receive data from WAL stream: FATAL:  terminating connection due to administrator command
cp: cannot stat '/var/lib/postgresql/9.5/main/archive/000000010000000000000016': No such file or directory
2017-11-30 19:09:51 KST [12936-6] LOG:  invalid record length at 0/16001330
2017-11-30 19:09:51 KST [13110-1] FATAL:  could not connect to the primary server: FATAL:  the database system is shutting down
        FATAL:  the database system is shutting down
```
### manual failover on slave
- Slave : manual Failover
```
$ touch /tmp/postgresql.trigger.5432
```
- Slave log
```
$ tail -f /var/log/postgresql/postgresql-9.5-main.log
2017-11-30 19:12:07 KST [12936-10] LOG:  archive recovery complete
2017-11-30 19:12:07 KST [12936-11] LOG:  MultiXact member wraparound protections are now enabled
2017-11-30 19:12:07 KST [12935-2] LOG:  database system is ready to accept connections
2017-11-30 19:12:07 KST [13210-1] LOG:  autovacuum launcher started
```
- Slave test
```
psql -c "select * from replica_test;"
psql -c "INSERT INTO replica_test VALUES ('slave is master');"
```
### manual recover master as slave
- Master : recover data from the lastest master 
```
rm -rf /var/lib/postgresql/9.5/main
pg_basebackup  -h 172.17.3.12 -U replica -D /var/lib/postgresql/9.5/main -P --xlog
```

- Master : start the server as slave
```
sudo systemctl start postgresql
```
- check master log
```
$ tail -f /var/log/postgresql/postgresql-9.5-main.log
2017-11-30 19:26:42 KST [30204-5] LOG:  MultiXact member wraparound protections are now enabled
2017-11-30 19:26:42 KST [30209-1] LOG:  autovacuum launcher started
2017-11-30 19:26:42 KST [30203-1] LOG:  database system is ready to accept connections
```
- check snapshot number on both
```
$ psql -c "SELECT txid_current_snapshot();"
 txid_current_snapshot
-----------------------
 635:635:
```


## [Go to 2nd chapter](postgresql-ha2.md)

## Reference
- [Google: Pgpool cluster](https://www.google.co.kr/search?q=pgtool+cluster&oq=pgtool+cluster&aqs=chrome..69i57j0l5.8079j0j7&sourceid=chrome&ie=UTF-8)
- http://www.devopsdays.in/postgresql-replication-failover-recovery-ubuntu-16-04/
- https://www.sraoss.co.jp/event_seminar/2016/pgpool-II-3.5.pdf
- http://www.pgpool.net/docs/pgpool-II-3.7.0/doc/en/html/example-configs.html
- hhttps://www.devmanuals.net/install/ubuntu/ubuntu-16-04-LTS-Xenial-Xerus/how-to-install-postgresql-9.5-pgpool2.html
- https://www.howtoforge.com/tutorial/how-to-set-up-master-slave-replication-for-postgresql-96-on-ubuntu-1604/
