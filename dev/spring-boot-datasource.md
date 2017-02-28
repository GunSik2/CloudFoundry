Step-by-step guide to add spirng cloud connector to spring boot app
===============
## Configuration
- pom.xml
```
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-cloud-connectors</artifactId>
		</dependency>
```
- CloudConfig.java
```
@Configuration
@Profile("cloud")
public class CloudConfig extends AbstractCloudConfig {
    @Bean
    public DataSource dataSource() {
        return connectionFactory().dataSource();
    }
}
```
- HelloController.java
```
@Controller
public class HomeController {
    @Autowired(required = false) DataSource dataSource;

    @RequestMapping("/")
    public String home(Model model) {
        model.addAttribute("datasource", ParseUtil.toString(dataSource));
        return "home";
    }   
}
```
- application.properties
```
spring.profiles.active: default
server.port: ${port:8080}
debug: true
```
- appliation-default.properties
```
# spring.datasource.url: jdbc:h2:mem:app
spring.datasource.max-active: 30
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.url: jdbc:mysql://127.0.0.1:3306/demo-cf-datasource
spring.datasource.username: root
spring.datasource.password: password
```
- manifest.yml
```
---
applications:
- name: demo-cf-datasource
  memory: 512M
  instances: 1
  host: demo-cf-datasource
  path: target/demo-cf-datasource-0.0.1-SNAPSHOT.war
  services:
  - my-mysql-db
  domain: paasta.koscom.co.kr
  buildpack: java_buildpack

```

## Reference
- https://github.com/cloudfoundry-samples/hello-spring-cloud
