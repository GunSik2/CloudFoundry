## How to push Go Revel framework to CloudFoundry

### Go App test
- Create env 
```
mkdir goapp; cd goapp
echo "export GOPATH=$(pwd)" > .env 
echo "export PATH=$PATH:$GOPATH/bin" >> .env
mkdir src/goapp/; cd src/goapp
```
- Create test app
```
# cat goapp.go
package main

import (
    "fmt"
    "net/http"
    "log"
    "os"
)

const (
    DEFAULT_PORT = "9000"
)

func HelloServer(w http.ResponseWriter, req *http.Request) {
    fmt.Fprintln(w, "Hello, World!n")
}

func main() {
    var port string
    if port = os.Getenv("PORT"); len(port) == 0 {
        log.Printf("Warning, PORT not set. Defaulting to %+vn", DEFAULT_PORT)
        port = DEFAULT_PORT
    }

    http.HandleFunc("/", HelloServer)
    err := http.ListenAndServe(":" + port, nil)
    if err != nil {
        log.Printf("ListenAndServe: ", err)
    }
}
```
- Test app in local
```
go run goapp.go
```
- Create manifest
```
# cat manifest.xml
applications:
  - name: goapp
    memory: 64M
    instances: 1
    buildpack: https://github.com/cloudfoundry/go-buildpack.git
    command: goapp

```
- Push app
```
# cf push
```

### Revel App test
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
