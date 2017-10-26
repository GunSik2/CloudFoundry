# Redis as Session repository instead of in-memory

- application.properties
```
# Redis
spring.redis.host=portal_redis_vip
#spring.redis.password=secret
spring.redis.port=6379
```

- pom.xml
```
		<dependency>
			<groupId>org.springframework.session</groupId>
			<artifactId>spring-session-data-redis</artifactId>
			<version>1.0.2.RELEASE</version>
		</dependency>


		<dependency>
			<groupId>org.springframework.session</groupId>
			<artifactId>spring-session</artifactId>
			<version>1.3.1.RELEASE</version>
		</dependency>
```

- HttpSessionConfig.java
```
package com.crossent.paasxpert.guide.session;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.session.data.redis.config.annotation.web.http.EnableRedisHttpSession;
import org.springframework.session.web.http.CookieSerializer;
import org.springframework.session.web.http.DefaultCookieSerializer;

@Configuration
@EnableRedisHttpSession
public class HttpSessionConfig {
}
```
