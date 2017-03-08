## How to push Go Revel framework to CloudFoundry

- Use godep
- Use 
```
export GOPATH="/home/me/gostuff"
cd $GOPATH
go get github.com/revel/revel
export PATH="$PATH:$GOPATH/bin"

revel new myapp
revel run myapp
cd src/myapp/
curl http://localhost:9000
```
```
cd $GOPATH/src/myapp
godep save ./app

cd Godeps/_workspace/src/github.com/revel/modules/testrunner
ls
# There is no `routes` directory, only `app`.
```
