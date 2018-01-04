package com.mossneto.greeter.controllers;

import com.mossneto.greeter.constants.Endpoints;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(Endpoints.GREETINGS)
public class GreetingController {
    private MessageSourceAccessor messages;

    @Autowired
    public GreetingController(final MessageSourceAccessor messages) {
        this.messages = messages;
    }

    @GetMapping
    @ApiOperation(value = "Greets you with static message")
    public ResponseEntity<String> staticGreetings() {
        return ResponseEntity.ok(this.messages.getMessage("greetphrase.simple"));
    }

    @PostMapping
    @ApiOperation(value = "Greets you with your name", notes = "Greets you with your name. You can specufy your name in Request BODY")
    public ResponseEntity<String> personalizedGreetings(@RequestBody final String name) {
        return ResponseEntity.ok(this.messages.getMessage("greetphrase.personal", new Object[] { name }));
    }
}
