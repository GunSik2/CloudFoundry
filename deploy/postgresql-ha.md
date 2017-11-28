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
## Configure Slave Server

## Reference
- [Google: Pgpool cluster](https://www.google.co.kr/search?q=pgtool+cluster&oq=pgtool+cluster&aqs=chrome..69i57j0l5.8079j0j7&sourceid=chrome&ie=UTF-8)
- https://www.sraoss.co.jp/event_seminar/2016/pgpool-II-3.5.pdf
- http://www.pgpool.net/docs/pgpool-II-3.7.0/doc/en/html/example-configs.html
- hhttps://www.devmanuals.net/install/ubuntu/ubuntu-16-04-LTS-Xenial-Xerus/how-to-install-postgresql-9.5-pgpool2.html
- https://www.howtoforge.com/tutorial/how-to-set-up-master-slave-replication-for-postgresql-96-on-ubuntu-1604/
