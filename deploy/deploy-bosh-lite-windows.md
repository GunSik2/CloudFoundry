
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
$ make_bosh_lite_v238.sh install
$ make_bosh_lite_v238.sh start
```



### bosh-lite start
- clone bosh-lite 
```
$ git clone https://github.com/cloudfoundry/bosh-lite
```
- Customize memory & cpu
```
$ cd bosh-lite
$ vi Vagrantfile
  config.vm.provider :virtualbox do |v, override|
    override.vm.box_version = '9000.137.0' # ci:replace
    v.customize ["modifyvm", :id, "--memory", 96000]
    v.customize ["modifyvm", :id, "--cpus", 10]
```
- Start bosh-lite
```
$ vagrant up
```


### Reference
- https://willplatnick.com/compacting-shrinking-a-virtualbox-image-when-using-vagrant-8a67af40417#.qwgt92gip
