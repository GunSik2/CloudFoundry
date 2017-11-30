# PostgreSQL + Pgpool2

## pgpool
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

- pgpool.conf 생성
```
sudo cp /usr/local/pgpool2/etc/pgpool.conf.sample-master-slave /usr/local/pgpool2/etc/pgpool
```


## Reference
- http://www.pgpool.net/docs/latest/en/html/admin.html
