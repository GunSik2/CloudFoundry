## How to push Go Revel framework to CloudFoundry

- Test Revel App  
```
mkdir revel; cd revel
echo "export GOPATH=$(pwd)" > .env 
echo "export PATH=$PATH:$GOPATH/bin" > .env
. .env
go get github.com/revel/revel
revel new myapp
revel run myapp

cd src/myapp/
curl http://localhost:9000
```

- Package using godep
```
cd src/myapp
godep save ./app

cd Godeps/_workspace/src/github.com/revel/modules/testrunner
ls
```
