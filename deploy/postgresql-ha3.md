# PostgreSQL + Pgpool2

## pgpool
- Ubuntu 용 pgpool-II 3.5 이상의 최신 버전이 없으므로 직접 빌드하여 배포(ubuntu 2.3 까지 제공)

- Source 에서 설치
```
apt-get update
apt-get install libpq-dev make
wget http://www.pgpool.net/download.php?f=pgpool-II-3.5.2.tar.gz -O pgpool-II-3.5.2.tar.gz
tar -xzf pgpool-II-3.5.2.tar.gz
rm pgpool-II-3.5.2.tar.gz
cd pgpool-II-3.5.2

./configure --prefix=/usr/share/pgpool2/3.5.2
make
make install
```

- Configure
```
cp /usr/share/pgpool2/3.5.2/etc/*.sample* /etc/pgpool2/3.5.2/

echo "export PATH=$PATH:/usr/share/pgpool2/3.5.2/bin/" >> ~/.bash_profile
. ~/.bash_profile
```

- Extension 설치
```
mkdir /etc/postgresql/9.5/main/sql
cp ~/pgpool-II-3.5.2/src/sql insert_lock.sql /etc/postgresql/9.5/main/sql/

cp ~/pgpool-II-3.5.2/pgpool_adm/pgpool_adm.control /usr/share/postgresql/9.5/extension/
cp ~/pgpool-II-3.5.2/pgpool_adm/pgpool_adm--1.0.sql /usr/share/postgresql/9.5/extension/
cp ~/pgpool-II-3.5.2/pgpool_adm/pgpool_adm.sql.in /usr/share/postgresql/9.5/extension/

cp ~/pgpool-II-3.5.2/pgpool-recovery/pgpool_recovery.control /usr/share/postgresql/9.5/extension/
cp ~/pgpool-II-3.5.2/pgpool-recovery/pgpool_recovery--1.1.sql /usr/share/postgresql/9.5/extension/
cp ~/pgpool-II-3.5.2/pgpool-recovery/pgpool-recovery.sql.in /usr/share/postgresql/9.5/extension/
cp ~/pgpool-II-3.5.2/pgpool-recovery/uninstall_pgpool-recovery.sql /usr/share/postgresql/9.5/extension/

cp ~/pgpool-II-3.5.2/pgpool-regclass/pgpool_regclass.control /usr/share/postgresql/9.5/extension/
cp ~/pgpool-II-3.5.2/pgpool-regclass/pgpool_regclass--1.0.sql /usr/share/postgresql/9.5/extension/
cp ~/pgpool-II-3.5.2/pgpool-regclass/pgpool-regclass.sql.in /usr/share/postgresql/9.5/extension/
cp ~/pgpool-II-3.5.2/pgpool-regclass/uninstall_pgpool-regclass.sql /usr/share/postgresql/9.5/extension/

-- /etc/postgresql/9.5/main/sql/*.sql 내용 중 MODULE_PATHNAME 을 /usr/lib/postgresql/9.5/lib/pgpool-recovery 로 변경
chown postgres:postgres -R /etc/postgresql/9.5/main/sql
```

- Init Script 업데이트
```

```
## Reference
- https://www.itenlight.com/blog/2016/05/21/PostgreSQL+HA+with+pgpool-II+-+Part+4
