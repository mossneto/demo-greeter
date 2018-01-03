package com.mossneto.greeter.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController("/greetings")
public class GreetingController {
    private MessageSourceAccessor messages;

    @Autowired
    public GreetingController(final MessageSourceAccessor messages) {
        this.messages = messages;
    }

    @GetMapping
    public ResponseEntity<String> staticGreetings() {
        return ResponseEntity.ok(this.messages.getMessage("greetphrase.simple"));
    }
}
