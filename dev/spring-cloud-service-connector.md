
## Base spring mvc3 application
```
git clone https://github.com/mkyong/spring3-mvc-maven-xml-hello-world
```

## Push base spring mv3 application
- Add manifiest file for cf push
  - We assumed mysql database instance is alread created in CF, named 'my-mysql-db'
```
cd spring3-mvc-maven-xml-hello-world
$ vi mainifest.yml
---
applications:
- name: spring3-mvc-maven-xml-hello-world
  memory: 512M
  host: spring3-mvc-maven-xml-hello-world
  domain: paasta.koscom.co.kr
  buildpack: java_buildpack
  services:
  - my-mysql-db
```

- Push spring mvc3 application to Cloud Foundry for test
```
cf push 
```

- Add spring service connector dependency to pom.xml
```
<dependencies>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-spring-service-connector</artifactId>
        <version>1.2.3.RELEASE</version>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-cloudfoundry-connector</artifactId>
        <version>1.2.3.RELEASE</version>
    </dependency>
</dependencies>
<repositories>
    <repository>
        <id>repository.springsource.milestone</id>
        <name>SpringSource Milestone Repository</name>
        <url>http://repo.springsource.org/milestone</url>
    </repository>
</repositories>
```

## Add/Modify Sources for spring cloud config
- Modify sourc: com.mkyong.web.controller.HelloController.java
```
@Controller
public class HelloController {
    @Autowired(required = false) DataSource dataSource;

	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String printWelcome(ModelMap model) {

		model.addAttribute("message", "Spring 3 MVC Hello World");
		model.addAttribute("datasource", ParseUtil.toString(dataSource)); // added
		
		System.err.println("datasource=" + ParseUtil.toString(dataSource)); // addded
		return "hello";

	}
  ...
}
```
- Modify source: hello.jsp
```
...
<div class="container">
  <div class="row">
  ...
  </div>
  <!-- add row for showing datasource -->
  <div class="row">
	  <div class="col-md-12">
	  		<c:if test="${not empty datasource}">
				DataSource binded = ${datasource}      
		</c:if>
	  </div>
  </div>
```
- Modify source: spring-web-servlet.xml
```
<!-- Add base package -->
	<context:component-scan base-package="com.mkyong.web, paasxpert.demo" /> 
```

- Add source: paasxpert.demo.spring.datasource.CloudConfig.java   
```
package paasxpert.demo.spring.datasource;

import javax.sql.DataSource;

import org.springframework.cloud.config.java.AbstractCloudConfig;
import org.springframework.cloud.config.java.ServiceScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@ServiceScan
@Profile("cloud")
public class CloudConfig extends AbstractCloudConfig {
    @Bean
    public DataSource dataSource() {
        return connectionFactory().dataSource();
    }
}
```
- Add source: : paasxpert.demo.spring.datasource.ParseUtil.java
```
package paasxpert.demo.spring.datasource;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.net.URI;
import java.net.URISyntaxException;

import javax.sql.DataSource;

import org.springframework.util.ReflectionUtils;

public class ParseUtil {
	
	   public static String toString(DataSource dataSource) {
	        if (dataSource == null) {
	            return "<none>";
	        } else {
	            try {
	                Field urlField = ReflectionUtils.findField(dataSource.getClass(), "url");
	                ReflectionUtils.makeAccessible(urlField);
	                return stripCredentials((String) urlField.get(dataSource));
	            } catch (Exception fe) {
	                try {
	                    Method urlMethod = ReflectionUtils.findMethod(dataSource.getClass(), "getUrl");
	                    ReflectionUtils.makeAccessible(urlMethod);
	                    return stripCredentials((String) urlMethod.invoke(dataSource, (Object[])null));
	                } catch (Exception me){
	                    return "<unknown> " + dataSource.getClass();                    
	                }
	            }
	        }
	    }
	    
	    private static String stripCredentials(String urlString) {
	        try {
	            if (urlString.startsWith("jdbc:")) {
	                urlString = urlString.substring("jdbc:".length());
	            }
	            URI url = new URI(urlString);
	            return new URI(url.getScheme(), null, url.getHost(), url.getPort(), url.getPath(), null, null).toString();
	        }
	        catch (URISyntaxException e) {
	            System.out.println(e);
	            return "<bad url> " + urlString;
	        }
	    }
	    
}
```
- Push again and test
```
cf push
```
