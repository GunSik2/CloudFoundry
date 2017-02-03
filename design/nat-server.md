## NAT confgiuration
- Add NAT VM
- NAT VM config
```
root@nat-cf:~# vi /etc/sysctl.conf
net.ipv4.ip_forward = 1
root@nat-cf:~# sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
root@nat-cf:~# sudo iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
root@nat-cf:~# sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
root@nat-cf:~# sudo sysctl -p
```
- Private subnet VM config (client)
```
# netstat -rn
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.178.63.129   0.0.0.0         UG        0 0          0 eth0
10.0.0.0        10.178.63.129   255.0.0.0       UG        0 0          0 eth0
161.26.0.0      10.178.63.129   255.255.0.0     UG        0 0          0 eth0

/:/home/vcap# ping google.com


/:/home/vcap# route add default gw 10.178.63.184
/:/home/vcap# netstat -rn
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.178.63.184   0.0.0.0         UG        0 0          0 eth0
0.0.0.0         10.178.63.129   0.0.0.0         UG        0 0          0 eth0
10.0.0.0        10.178.63.129   255.0.0.0       UG        0 0          0 eth0
10.178.63.128   0.0.0.0         255.255.255.192 U         0 0          0 eth0
161.26.0.0      10.178.63.129   255.255.0.0     UG        0 0          0 eth0

/:/home/vcap# route del default gw 10.178.63.129
/:/home/vcap# netstat -rn
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.178.63.184   0.0.0.0         UG        0 0          0 eth0
10.0.0.0        10.178.63.129   255.0.0.0       UG        0 0          0 eth0
10.178.63.128   0.0.0.0         255.255.255.192 U         0 0          0 eth0
161.26.0.0      10.178.63.129   255.255.0.0     UG        0 0          0 eth0

/:/home/vcap# ping google.com
PING google.com (216.58.200.174) 56(84) bytes of data.
64 bytes from nrt12s11-in-f14.1e100.net (216.58.200.174): icmp_seq=2 ttl=53 time=33.8 ms
64 bytes from nrt12s11-in-f14.1e100.net (216.58.200.174): icmp_seq=3 ttl=53 time=33.0 ms
64 bytes from nrt12s11-in-f14.1e100.net (216.58.200.174): icmp_seq=4 ttl=53 time=32.7 ms
```
