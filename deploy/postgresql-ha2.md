# PostgreSQL + Pgpool2

## pgpool2 설치
'''
sudo apt install pgpool2
'''

## pgpool2 설정
- /etc/pgpool2/pgpool.conf
```
listen_addresses = '*'

backend_hostname1 = '172.17.3.9'
backend_port1 = 5432
backend_weight1 = 1
backend_data_directory1 = '/var/lib/postgresql/9.5/main/'
backend_flag1 = 'ALLOW_TO_FAILOVER'

backend_hostname1 = '172.17.3.12'
backend_port1 = 5432
backend_weight1 = 1
backend_data_directory1 = '/var/lib/postgresql/9.5/main/'
backend_flag1 = 'ALLOW_TO_FAILOVER'

enable_pool_hba = on
```

- /etc/pgpool2/pool_hba.conf
```
host    all         all         172.17.3.0/24        md5
```
- generate md5 password
```
$ sudo pg_md5 -m -u postgres -p
$ cat /etc/pgpool2/pool_passwd
```


## pgpool2 시작/중지
- 시작
```
sudo service pgpool2 start
```
- 중지
```
sudo service pgpool2 stop
```
- 시작 에러조치
```
$ sudo service pgpool2 start
Dec  4 13:35:05 portal-svc-db-01 systemd[1]: Started pgpool-II.
ubuntu@portal-svc-db-01:~$ Dec  4 13:35:05 portal-svc-db-01 pgpool[16664]: 2017-12-04 13:35:05: pid 16664: FATAL:  failed to bind a socket: "/var/run/postgresql/.s.PGSQL.5433"
Dec  4 13:35:05 portal-svc-db-01 pgpool[16664]: 2017-12-04 13:35:05: pid 16664: DETAIL:  bind socket failed with error: "Address already in use"
Dec  4 13:35:05 portal-svc-db-01 systemd[1]: pgpool2.service: Main process exited, code=exited, status=3/NOTIMPLEMENTED
Dec  4 13:35:05 portal-svc-db-01 systemd[1]: pgpool2.service: Unit entered failed state.
Dec  4 13:35:05 portal-svc-db-01 systemd[1]: pgpool2.service: Failed with result 'exit-code'.

~$ sudo rm -f /var/run/postgresql/.s.PGSQL.*
```

## 테스트
- pgpool 접속 조회
```
$ psql -U postgres -p 5433 -c 'select application_name, state, sync_priority, sync_state from pg_stat_replication;'
```



## Reference
- http://www.pgpool.net/docs/latest/en/html/admin.html
- https://sonnguyen.ws/replication-load-balance-in-posgresql-replication-with-pgpool2/
- http://www.pgpool.net/docs/pgpool-II-3.5.4/doc/pgpool-en.html
- https://www.itenlight.com/blog/2016/05/21/PostgreSQL+HA+with+pgpool-II+-+Part+5
- https://blog.dbi-services.com/vertically-scale-your-postgresql-infrastructure-with-pgpool-2-automatic-failover-and-reconfiguration/
- http://www.pgpool.net/docs/pgpool-II-3.7.0/doc/en/html/example-cluster.html
