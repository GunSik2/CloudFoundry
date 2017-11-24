# VIP Service using keepalived and haproxy

- Install
```
sudo add-apt-repository ppa:vbernat/haproxy-1.5
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get install haproxy -y


sudo apt-get install mysql-client -y
sudo apt-get install keepalived -y
sudo apt-get install mysql-client -y
```
- Linux kernel option for vip
```
$ sudo vi /etc/sysctl.conf
net.ipv4.ip_nonlocal_bind=1

$ sudo sysctl -p
```
- create mysql user for service check 
```
$ mysql -u root -p
> USE mysql;
> CREATE USER 'haproxytest'@'%';
```
- haproxy.cfg
```
global
    log 127.0.0.1 local0 notice
    user haproxy
    group haproxy

defaults
    log global
    retries 2
    timeout connect 3000
    timeout server 10m
    timeout client 10m

listen galera
    bind *:3306
    balance source
    mode tcp
    option tcpka
    option mysql-check user haproxytest
    server mysql-1 172.19.2.2:3306 check weight 1
    server mysql-2 172.19.2.10:3306 check weight 1
    server mysql-3 172.19.2.13:3306 check weight 1

listen redis
    bind *:6379
    option tcp-check
    tcp-check connect
    tcp-check send PING\r\n
    tcp-check expect string +PONG
    tcp-check send info\ replication\r\n
    tcp-check expect string role:master
    tcp-check send QUIT\r\n
    tcp-check expect string +OK
    server redis_1 172.19.2.14:6379 check inter 1s
    server redis_2 172.19.2.4:6379 check inter 1s


listen uaa
    bind *:8080
    mode tcp
    balance source
    option tcpka
    server node0 172.19.2.12:8080 check inter 1s fall 3 rise 2 #inter 1s #fall 3 rise 2
    server node1 172.19.2.8:8080 check inter 1s fall 3 rise 2 #inter 1s #fall 3 rise 2


listen monitor
    bind *:8880
    mode            http
    log             global
    maxconn 10
    timeout client      100s
    timeout server      100s
    timeout connect      100s
    timeout queue   100s
    stats enable
    stats hide-version
    stats refresh 30s
    stats show-node
    stats auth admin:password
    stats uri  /haproxy?stats
```

- keepalived.conf (master)
```
global_defs {
        vrrp_version 3
        vrrp_iptables
        vrrp_garp_master_repeat 5
        vrrp_garp_master_delay 1
        vrrp_check_unicast_src
}

vrrp_script haproxy {
    script "killall -0 haproxy"
    interval 2
    fall 2       # require 2 failures for KO
    rise 2       # require 2 successes for OK
}

vrrp_instance VI_1 {
    state BACKUP
    interface ens3
    virtual_router_id 10
    priority 101
    advert_int 1
    nopreempt
    unicast_src_ip 172.19.2.242
    unicast_peer {
        172.19.2.243
    }
    virtual_ipaddress {
        172.19.2.241/24 dev ens3
    }
    track_script {
        haproxy
    }
}
```

- keeepalived.conf (slave)
```
global_defs {
        vrrp_version 3
        vrrp_iptables
        vrrp_garp_master_repeat 5
        vrrp_garp_master_delay 1
        vrrp_check_unicast_src
}


vrrp_script haproxy {
    script "killall -0 haproxy"
    interval 2
    fall 2       # require 2 failures for KO
    rise 2       # require 2 successes for OK
}
vrrp_instance VI_1 {
    state BACKUP
    interface ens3
    virtual_router_id 10
    priority 95
    advert_int 1
    nopreempt
    unicast_src_ip 172.19.2.243
    unicast_peer {
        172.19.2.242
    }
    virtual_ipaddress {
        172.19.2.241/24 dev ens3
    }
    track_script {
        haproxy
    }
}
```
