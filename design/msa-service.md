
PaaS Service for MSA
=====
## Movivation
How to implement microservice architecture style services in PaaS?

## What is microservice architecture style?

## What services are necessary to support MSA?

## What problems need to be resoved in MSA?
How do the clients of a Microservices-based application access the individual services? API gateway that is the single entry point for all clients

How does the client of a service - the API gateway or another service - discover the location of a service instance?  Service Registry
How to prevent a network or service failure from cascading to other services? Circuit Breaker

## How PaaS support MSA?
PCF provides three services from Neflix OSS.
- [Config Server]((http://docs.pivotal.io/spring-cloud-services/1-3/common/config-server/index.html)), powered by [Spring Cloud Config](http://cloud.spring.io/spring-cloud-config/), and backed by a customer-provided Git or SVN repository.
- Service Registry, powered by the battle-tested NetflixOSS [Eureka server](https://github.com/Netflix/eureka/wiki).
- Circuit Breaker Dashboard, powered by the combination of NetflixOSS [Turbine](https://github.com/Netflix/Turbine/wiki) and [Hystrix](https://github.com/Netflix/Hystrix/wiki).

[Amalgam8](https://www.amalgam8.io/docs/)


## Reference
- [microservices.io](http://microservices.io/index.html)
- [Netflix OSS](https://netflix.github.io/)
- [Pivotal Cloud Foundry Adds Netflix OSS Services, Docker Support](https://www.infoq.com/news/2015/11/pivotal-cloud-foundry-netflix)
- [Config Server for Pivotal Cloud Foundry]
- [cf-networking-release](https://github.com/cloudfoundry-incubator/cf-networking-release)


