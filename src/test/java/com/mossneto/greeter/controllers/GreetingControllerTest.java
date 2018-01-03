package com.mossneto.greeter.controllers;

import com.mossneto.greeter.constants.Endpoints;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@RunWith(SpringRunner.class)
@WebMvcTest(GreetingController.class)
public class GreetingControllerTest {
    private static final Logger LOG = LoggerFactory.getLogger(GreetingControllerTest.class);

    @Autowired
    private MockMvc mvc;

    @Test
    public void receivedStaticGreets() throws Exception {
        this.mvc.perform(get(Endpoints.GREETINGS))
                .andExpect(status().isOk())
                .andExpect(content().string(Expectations.SUCCESS_STATIC_PHRASE));
    }

    @Test
    public void receivedPersonalizedGreets() throws Exception {
        for (String name : Expectations.NAMES) {
            this.mvc.perform(post(Endpoints.GREETINGS).content(name))
                    .andExpect(status().isOk())
                    .andExpect(content().string(String.format(Expectations.SUCCESS_PERSONAL_PHRASE, name)));
        }
    }

    @Test
    public void rejectedOnEmptyName() throws Exception {
        this.mvc.perform(post(Endpoints.GREETINGS).content(""))
                .andExpect(status().isBadRequest());
    }

    private static class Expectations {
        public static final String SUCCESS_STATIC_PHRASE = "Hello World!";
        public static final String SUCCESS_PERSONAL_PHRASE = "Hello %s World!";

        public static final String[] NAMES = new String[] { "Bruce", "Peter", "1", "@", "$", "//", "\\" };

        private Expectations() {
            // DO NOTHING.
        }
    }
}
