# PostgreSQL + PGPool

## Env
- Master (172.17.3.9) accepts connections from the client with read and write permissions
- Slave (172.17.3.12) the standby server runs a copy of the data from the master server with read-only permission.
- VIP (172.17.3.8) 

![](https://user-images.githubusercontent.com/11453229/33374601-311f6c12-d54a-11e7-99d2-6983a6ee4e7f.png)


## Boath Master and Slave
- Install PostgreSQL Master/Slave
```
sudo apt update
sudo apt install postgresql-9.5-pgpool2 -y
```
- Check
```
$ dpkg -l | grep post
ii  postgresql-9.5                   9.5.10-0ubuntu0.16.04                      amd64        object-relational SQL database, version 9.5 server
ii  postgresql-9.5-pgpool2           3.4.3-1                                    amd64        connection pool server and replication proxy for PostgreSQL - modules
ii  postgresql-client-9.5            9.5.10-0ubuntu0.16.04                      amd64        front-end programs for PostgreSQL 9.5
ii  postgresql-client-common         173ubuntu0.1                               all          manager for multiple PostgreSQL client versions
ii  postgresql-common                173ubuntu0.1                               all          PostgreSQL database-cluster manager
ii  postgresql-contrib-9.5           9.5.10-0ubuntu0.16.04                      amd64        additional facilities for PostgreSQL
```

- copy ssh key to oppsite server for the both servers
```
sudo su - postgres
ssh-keygen
cat /var/lib/postgresql/.ssh/id_rsa.pub  // copy it to the oppistie server (~/.ssh/authorized_keys)
```

- /etc/postgresql/9.5/main/recovery.conf.pgpool
```
standby_mode = 'on'
primary_conninfo = 'host=172.17.3.8 port=5432 user=rep password=yourpassword'
trigger_file = '/tmp/postgresql.trigger.5432'
```

## Create 

## Master Server
- Set postgres password
psql -c '\password postgres'
```

- Create an account for replication
```
sudo su - postgres
psql -c "CREATE USER rep REPLICATION LOGIN CONNECTION LIMIT 1 ENCRYPTED PASSWORD 'yourpassword';"
```

- /etc/postgresql/9.5/main/pg_hba.conf
```
host    replication     rep        172.17.3.12/32          md5
```

- /etc/postgresql/9.5/main/postgresql.conf
```
listen_addresses = '*'
wal_level = 'hot_standby'
archive_mode = on
archive_command = 'cd .'
max_wal_senders = 1
hot_standby = on
```
- restart master server
```
sudo systemctl restart postgresql
```

## Slave Server
- Stop postgresql
```
sudo systemctl stop postgresql
```

- /etc/postgresql/9.5/main/pg_hba.conf
```
host    replication     rep        172.17.3.9/32          md5
```

- /etc/postgresql/9.5/main/postgresql.conf
```
listen_addresses = '*'
wal_level = 'hot_standby'
archive_mode = on
archive_command = 'cd .'
max_wal_senders = 1
hot_standby = on
```
- Start replication
```
rm -rf /var/lib/postgresql/9.5/main
pg_basebackup  -h 172.17.3.9 -U rep -D /var/lib/postgresql/9.5/main -P --xlog
cp /etc/postgresql/9.5/main/recovery.conf.pgpool /var/lib/postgresql/9.5/main/recovery.conf
```

- start the slave server
```
$ sudo systemctl start postgresql

$ tail -f /var/log/postgresql/postgresql-9.5-main.log
2017-12-04 11:34:37 KST [27019-2] LOG:  entering standby mode
2017-12-04 11:34:37 KST [27020-1] LOG:  started streaming WAL from primary at 0/3000000 on timeline 1
2017-12-04 11:34:37 KST [27019-3] LOG:  redo starts at 0/3000028
2017-12-04 11:34:37 KST [27019-4] LOG:  consistent recovery state reached at 0/3000130
2017-12-04 11:34:37 KST [27018-1] LOG:  database system is ready to accept read only connections
```


## Testing
- @Master: Check cluster status
```
$ su - postgres
$ psql -c "select application_name, state, sync_priority, sync_state from pg_stat_replication;"
 application_name |   state   | sync_priority | sync_state
------------------+-----------+---------------+------------
 walreceiver      | streaming |             0 | async

$ psql -c "SELECT txid_current_snapshot();"
 txid_current_snapshot
-----------------------
 628:628:
```

- @Master: Create table 
```
su - postgres
psql
CREATE TABLE replica_test (hakase varchar(100));
INSERT INTO replica_test VALUES ('howtoforge.com');
select * from replica_test;
```
- @Slave
```
su - postgres
psql -c "select * from replica_test;"
psql -c "INSERT INTO replica_test VALUES ('this is SLAVE');"
ERROR:  cannot execute INSERT in a read-only transaction
```

## Manual Failover 
### kill master process
- @Maser: kill process
```
killall postgres
```
- @Slave : log
```
$ tail -f /var/log/postgresql/postgresql-9.5-main.log
2017-12-04 11:42:43 KST [27133-1] FATAL:  could not connect to the primary server: could not connect to server: Connection refused
                Is the server running on host "172.17.3.9" and accepting
                TCP/IP connections on port 5432?
```

### failover on slave
- @Slave : manual Failover
```
$ touch /tmp/postgresql.trigger.5432
```
- @Slave log
```
$ tail -f /var/log/postgresql/postgresql-9.5-main.log
2017-12-04 11:43:58 KST [27019-6] LOG:  trigger file found: /tmp/postgresql.trigger.5432
2017-12-04 11:43:58 KST [27019-7] LOG:  redo done at 0/40159D8
2017-12-04 11:43:58 KST [27019-8] LOG:  last completed transaction was at log time 2017-12-04 11:39:59.911413+09
2017-12-04 11:43:58 KST [27019-9] LOG:  selected new timeline ID: 2
2017-12-04 11:43:59 KST [27019-10] LOG:  archive recovery complete
2017-12-04 11:43:59 KST [27019-11] LOG:  MultiXact member wraparound protections are now enabled
2017-12-04 11:43:59 KST [27018-2] LOG:  database system is ready to accept connections
2017-12-04 11:43:59 KST [27150-1] LOG:  autovacuum launcher started
```
- @Slave test
```
psql -c "select * from replica_test;"
psql -c "INSERT INTO replica_test VALUES ('slave is master');"
```
- @Slave remove trigger
```
rm /tmp/postgresql.trigger.5432
```

### manual recover master as slave
- @OldMaster : recover data from the lastest master 
```
rm -rf /var/lib/postgresql/9.5/main
pg_basebackup  -h 172.17.3.12 -U rep -D /var/lib/postgresql/9.5/main -P --xlog
cp /etc/postgresql/9.5/main/recovery.conf.pgpool /var/lib/postgresql/9.5/main/recovery.conf
```

- @OldMaster : start the server as slave
```
sudo systemctl start postgresql
```
- check master log
```
$ tail -f /var/log/postgresql/postgresql-9.5-main.log
2017-12-04 12:19:02 KST [14035-1] LOG:  database system was interrupted; last known up at 2017-12-04 12:16:51 KST
2017-12-04 12:19:02 KST [14035-2] LOG:  entering standby mode
2017-12-04 12:19:02 KST [14035-3] LOG:  redo starts at 0/A000028
2017-12-04 12:19:02 KST [14035-4] LOG:  consistent recovery state reached at 0/A0000F8
2017-12-04 12:19:02 KST [14034-1] LOG:  database system is ready to accept read only connections
2017-12-04 12:19:02 KST [14039-1] LOG:  started streaming WAL from primary at 0/B000000 on timeline 2
2017-12-04 12:19:02 KST [14040-1] [unknown]@[unknown] LOG:  incomplete startup packet
```
- check snapshot number on both
```
$ psql -c "select application_name, state, sync_priority, sync_state from pg_stat_replication;"
 application_name |   state   | sync_priority | sync_state
------------------+-----------+---------------+------------
 walreceiver      | streaming |             0 | async
 
$ psql -c "SELECT txid_current_snapshot();"
 txid_current_snapshot
-----------------------
 628:628:
```


## [Go to 2nd chapter](postgresql-ha2.md)

## Reference
- [Google: Pgpool cluster](https://www.google.co.kr/search?q=pgtool+cluster&oq=pgtool+cluster&aqs=chrome..69i57j0l5.8079j0j7&sourceid=chrome&ie=UTF-8)
- http://www.devopsdays.in/postgresql-replication-failover-recovery-ubuntu-16-04/
- https://www.sraoss.co.jp/event_seminar/2016/pgpool-II-3.5.pdf
- http://www.pgpool.net/docs/pgpool-II-3.7.0/doc/en/html/example-configs.html
- hhttps://www.devmanuals.net/install/ubuntu/ubuntu-16-04-LTS-Xenial-Xerus/how-to-install-postgresql-9.5-pgpool2.html
- https://www.howtoforge.com/tutorial/how-to-set-up-master-slave-replication-for-postgresql-96-on-ubuntu-1604/
- https://blog.qodot.me/post/postgresql-replication-%EA%B5%AC%EC%B6%95%ED%95%98%EA%B8%B0/
