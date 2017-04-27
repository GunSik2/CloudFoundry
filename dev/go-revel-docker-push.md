
Revel Project 생성
```
mkdir -p revel; cd revel
export GOPATH=$(pwd)
go get github.com/revel/revel
go get go get github.com/revel/cmd/revel
bin/revel new hellogo
bin/revel build hellogo dev
```

Dockerfile 생성
```
vi Dockerfile
---
FROM golang:1.7.4

ADD . /go 
RUN go get github.com/revel/revel
 
WORKDIR /go
ENTRYPOINT dev/run.sh
EXPOSE 9000
```

Docker 빌드 및 배포
```
docker build -t cgshome2/hellogo .
docker images
docker run -it -p 9000:9000 --rm cgshome2/hellogo  # test
docker login # Login to docker hub
docker push cgshome2/hellogo
```

CF 배포
```
cf login
cf push -o cgshome2/hellogo
```

Github과 연동한 자동 빌드 및 배포
- Docker hub 로그인 후 Create > Create Automated Build 메뉴에서 설정 등록
