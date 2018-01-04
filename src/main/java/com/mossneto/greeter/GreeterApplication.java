package com.mossneto.greeter;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.support.MessageSourceAccessor;

@SpringBootApplication
public class GreeterApplication {
	@Bean
	public MessageSourceAccessor messageAccessor(final MessageSource messageSource) {
		return new MessageSourceAccessor(messageSource);
	}

	public static void main(String[] args) {
		SpringApplication.run(GreeterApplication.class, args);
	}
}
