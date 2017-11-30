# PostgreSQL + Pgpool2

## pgpool2 설치
- Ubuntu 용 pgpool-II 3.5 이상의 최신 버전이 없으므로 직접 빌드하여 배포(ubuntu 3.4 까지 제공)

- pgpool 설치
```
apt-get update
apt-get install libpq-dev make gcc postgresql-server-dev-all

wget http://www.pgpool.net/download.php?f=pgpool-II-3.7.0.tar.gz -O pgpool-II-3.7.0.tar.gz
tar xvzf pgpool-II-3.7.0.tar.gz; cd pgpool-II-3.7.0

./configure --prefix=/usr/local/pgpool2
make
make install
```

- pgpool_recovery 설치
```
cd src/sql/pgpool-recovery
make
make install

sudo su - postgres
psql -f /home/ubuntu/pgpool-II-3.7.0/src/sql/pgpool-recovery/pgpool-recovery.sql template1
exit

sudo sh -c "echo pgpool.pg_ctl = '/usr/lib/postgresql/9.5/bin/pg_ctl' >> /etc/postgresql/9.5/main/postgresql.conf"

#pg_ctl reload -D /usr/lib/postgresql/9.5/data
```

- configuration file 생성
```
sudo cp /usr/local/pgpool2/etc/pgpool.conf.sample-stream /usr/local/pgpool2/etc/pgpool.conf
sudo cp /usr/local/pgpool2/etc/pcp.conf.sample /usr/local/pgpool2/etc/pcp.conf
```

## pgpool2 설정
- pgpool2 admin password 생성 및 설정
```
$ /usr/local/pgpool2/bin/pg_md5 your_password
e5624f3f6dd941f9a4e181013fa1b7fd

$ sudo sh -c "echo 'admin:e5624f3f6dd941f9a4e181013fa1b7fd' >> /usr/local/pgpool2/etc/pcp.conf"
```

- /usr/local/pgpool2/etc/pgpool.conf
```
listen_addresses = '*'
#port = 5432
socket_dir = '/var/run/postgresql'

#pcp_listen_addresses = '*'
#pcp_port = 9898
pcp_socket_dir = '/var/run/postgresql'


backend_hostname0 = '172.17.3.9'
backend_port0 = 5433
backend_weight0 = 1
backend_data_directory0 = '/var/lib/postgresql/9.5/main/'
backend_flag0 = 'ALLOW_TO_FAILOVER'

backend_hostname1 = '172.17.3.12'
backend_port1 = 5433
backend_weight1 = 1
backend_data_directory1 = '/var/lib/postgresql/9.5/main/'
backend_flag1 = 'ALLOW_TO_FAILOVER'

#pid_file_name = '/var/run/pgpool/pgpool.pid' #/var/run/postgresql/pgpool.pid'
#replication_mode = off   #we are not using replication mode but master/slave streaming mode.
#load_balance_mode = on

#master_slave_mode = on
#master_slave_sub_mode = 'stream'
sr_check_period = 5
sr_check_user = 'postgres'
sr_check_password = 'changeit'

helth_check_period = 5
health_check_timeout = 0
helth_check_user = 'postgres'
health_check_password = 'changeit'

failover_command = '/etc/pgpool2/3.5.2/failover.sh %d %P %H myreplicationpassword /etc/postgresql/9.5/main/im_the_master'


```

## pgpool2 시작
```
```

## Reference
- http://www.pgpool.net/docs/latest/en/html/admin.html
- https://www.itenlight.com/blog/2016/05/21/PostgreSQL+HA+with+pgpool-II+-+Part+5
- https://blog.dbi-services.com/vertically-scale-your-postgresql-infrastructure-with-pgpool-2-automatic-failover-and-reconfiguration/
