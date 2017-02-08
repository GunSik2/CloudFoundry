# Effeicent way to manage bosh-lite

## recover process after bosh-lite stop/start
- delete & redeploy deployments
```
$ bosh delete deployment cf
$ bosh deployment cf.yml
$ bosh -n deploy
```
- Fort forwarding: In case of cf, 80 & 443 port forwarding necessary
```
$ sudo iptables -A FORWARD -p tcp -d 10.244.0.34 --dport 443 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$ sudo iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 443 -j DNAT --to-destination 10.244.0.34:443

$ sudo iptables -A FORWARD -p tcp -d 10.244.0.34 --dport 80 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$ sudo iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 80 -j DNAT --to-destination 10.244.0.34:80
```

## managing multiple bosh-lite
- use snowwhite: https://github.com/cloudfoundry-community/snowwhite


## Reference
- run concourse on bosh-lite: http://www.starkandwayne.com/blog/run-concourse-on-bosh-lite-on-aws/
