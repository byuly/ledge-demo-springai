package com.ledge.codewhisperer.config;

import io.ledge.sdk.spring.LedgeObservationAdvisor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.SimpleLoggerAdvisor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ChatClientConfig {

    @Bean
    public ChatClient chatClient(ChatClient.Builder builder,
                                 @Autowired(required = false) LedgeObservationAdvisor ledgeAdvisor) {
        var b = builder.defaultAdvisors(new SimpleLoggerAdvisor());
        if (ledgeAdvisor != null) {
            b = b.defaultAdvisors(ledgeAdvisor);
        }
        return b.build();
    }
}
