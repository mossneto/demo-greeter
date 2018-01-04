package com.mossneto.greeter;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.Contact;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

import java.util.ArrayList;

@EnableSwagger2
@Configuration
public class SwaggerConfig {
    @Value("${spring.application.name}")
    private String appName;

    // http://localhost:8080/swagger-ui.html
    @Bean
    public Docket api() {
        return new Docket(DocumentationType.SWAGGER_2)
                .select()
                .apis(RequestHandlerSelectors.basePackage(this.getClass().getPackage().getName()))
                .paths(PathSelectors.any())
                .build()
                .apiInfo(apiInfo());
    }

    private ApiInfo apiInfo() {
        final Contact contact = new Contact("Mos",
                "TBD",
                "mossneto@gmail.com");
        return new ApiInfo(
                this.appName,
                "Greeting Micro Service",
                "1",
                null,
                new Contact(
                        "Mos",
                        "TBD",
                        "mossneto@gmail.com"),
                "Apache License",
                "https://www.apache.org/licenses/LICENSE-2.0",
                new ArrayList<>());
    }
}
