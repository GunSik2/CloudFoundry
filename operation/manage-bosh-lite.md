# Effeicent way to manage bosh-lite

## recover process after bosh-lite stop/start
- delete & redeploy deployments
```
$ bosh delete deployment cf
$ bosh deployment cf.yml
$ bosh -n deploy
```
- Fort forwarding: In case of cf, 80(apps) & 443(api), 4443(loggregator), 2222(ssh) port forwarding necessary
```
$ sudo iptables -A FORWARD -p tcp -d 10.244.0.34 --dport 443 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$ sudo iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 443 -j DNAT --to-destination 10.244.0.34:443

$ sudo iptables -A FORWARD -p tcp -d 10.244.0.34 --dport 80 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$ sudo iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 80 -j DNAT --to-destination 10.244.0.34:80

$ sudo iptables -A FORWARD -p tcp -d 10.244.0.34 --dport 4443 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$ sudo iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 4443 -j DNAT --to-destination 10.244.0.34:4443

$ sudo iptables -A FORWARD -p tcp -d 10.244.0.34 --dport 2222 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$ sudo iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 2222 -j DNAT --to-destination 10.244.0.34:2222
```

## managing multiple bosh-lite
- use snowwhite: https://github.com/cloudfoundry-community/snowwhite


## Reference
- run concourse on bosh-lite: http://www.starkandwayne.com/blog/run-concourse-on-bosh-lite-on-aws/
- run cf on bosh-: http://pythonhackers.com/p/michaelklishin/bosh-lite
