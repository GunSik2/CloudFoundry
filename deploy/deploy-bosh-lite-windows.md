
### Overview
We will deploy cf/diego on windows. 
We will deploy two virutal machines, inception and bosh-lite. 
Inception vm will install all required packages for compiling and installing cf/diego.
Bosh-lite vm will run microbosh and cf/diego.

In general virtualbox image size is increased when we deploy multiple times. 
To minimize the image size, we will create and mount shared host folders:

```
mkdir /vagrant/.bosh; ln -s /vagrant/.bosh .
```



### bosh-lite start
- clone bosh-lite 
```
$ git clone https://github.com/cloudfoundry/bosh-lite
```
- Customize memory/memory/bridged network if necessary.
```
$ cd bosh-lite
$ vi Vagrantfile
  config.vm.provider :virtualbox do |v, override|
    override.vm.box_version = '9000.137.0' # ci:replace
    v.customize ["modifyvm", :id, "--memory", 96000]
    v.customize ["modifyvm", :id, "--cpus", 10]
    override.vm.network :public_network, bridge: 'en0: Ethernet 1', ip: '10.10.10.15', subnet: '255.255.255.0'    
```

- Start bosh-lite
```
$ vagrant up
```

### inception deployment
- create inception
```
vagrant init ubuntu/trusty64; vagrant up --provider virtualbox
```

- login to bosh-lite
```
$ vagrant ssh
```

- configure run script: 
```
$ make_bosh_lite.sh prepare
$ make_bosh_lite.sh deploy
```

#### bosh-lite access
- add route @bosh-lite (bosh-lite/bin/add-route)
```
route add 10.244.0.0/19 192.168.50.4
```

- manual ssh tunneling @host
```
ssh -L 80:127.0.0.1:80 vagrant@127.0.0.1 -p 2222
```

### Reference
- https://willplatnick.com/compacting-shrinking-a-virtualbox-image-when-using-vagrant-8a67af40417#.qwgt92gip
- http://software.danielwatrous.com/explore-cloudfoundry-using-bosh-lite-on-windows/
- http://superuser.com/questions/752954/need-to-do-bridged-adapter-only-in-vagrant-no-nat
- http://serverfault.com/questions/418422/public-static-ip-for-vagrant-box
