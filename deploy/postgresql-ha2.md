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

#pg_ctl reload -D /var/lib/postgresql/9.5/main
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
port = 5432  #9999
socket_dir = '/var/run/postgresql'

#pcp_listen_addresses = '*'
#pcp_port = 9898
pcp_socket_dir = '/var/run/postgresql'

backend_hostname0 = '172.17.3.9'
backend_port0 = 5432 
backend_weight0 = 1
backend_data_directory0 = '/var/lib/postgresql/9.5/main/'
backend_flag0 = 'ALLOW_TO_FAILOVER'

backend_hostname1 = '172.17.3.12'
backend_port1 = 5432
backend_weight1 = 1
backend_data_directory1 = '/var/lib/postgresql/9.5/main/'
backend_flag1 = 'ALLOW_TO_FAILOVER'

#pid_file_name = '/var/run/postgresql/pgpool.pid'
#replication_mode = off   #we are not using replication mode but master/slave streaming mode.
#load_balance_mode = on

#master_slave_mode = on
#master_slave_sub_mode = 'stream'
sr_check_period = 5
sr_check_user = 'replica'
sr_check_password = 'changeit'
sr_check_database = 'aqwe123@'

helth_check_period = 5
health_check_timeout = 0
helth_check_user = 'replica'
health_check_password = 'aqwe123@'

follow_master_command = ''
failover_command = '/etc/pgpool2/3.5.2/failover.sh %d %P %H myreplicationpassword /etc/postgresql/9.5/main/im_the_master'

recovery_user = 'replica'
recovery_password = 'aqwe123@'
recovery_1st_stage_command = ''
recovery_2nd_stage_command = ''

#------------
# WATCHDOG
#------------
use_watchdog = on
trusted_servers = '172.17.3.8,172.17.3.12'

wd_hostname = '172.17.3.9' # Host name or IP address of this watchdog

# - Virtual IP control Setting -
delegate_IP = '172.17.3.8'
if_up_cmd = 'ip addr add $_IP_$/24 dev ens3 label ens3:0'
if_down_cmd = 'ip addr del $_IP_$/24 dev ens3'
arping_cmd = 'arping -U $_IP_$ -w 1'

# - Lifecheck Setting -
wd_monitoring_interfaces_list = 'ens3'  
wd_lifecheck_method = 'heartbeat'

# -- heartbeat mode --
heartbeat_destination0 = '172.17.3.9'
heartbeat_destination_port0 = 9694
heartbeat_device0 = 'ens3'

heartbeat_destination1 = '172.17.3.12'
heartbeat_destination_port1 = 9694
heartbeat_device1 = 'ens3'

wd_lifecheck_user = 'replica'
wd_lifecheck_password = 'aqwe123@'
```



## pgpool2 시작
```
$ export PATH=$PATH:/usr/local/pgpool2/bin/
$ pgpool -m fast stop
$ pcp_watchdog_info

postgres=# show pool_nodes;
```

## Reference
- http://www.pgpool.net/docs/latest/en/html/admin.html
- https://sonnguyen.ws/replication-load-balance-in-posgresql-replication-with-pgpool2/
- https://www.itenlight.com/blog/2016/05/21/PostgreSQL+HA+with+pgpool-II+-+Part+5
- https://blog.dbi-services.com/vertically-scale-your-postgresql-infrastructure-with-pgpool-2-automatic-failover-and-reconfiguration/
- http://www.pgpool.net/docs/pgpool-II-3.7.0/doc/en/html/example-cluster.html
