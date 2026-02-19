package com.ledge.codewhisperer.service;

import com.ledge.codewhisperer.model.CodeProfile;
import com.ledge.codewhisperer.model.WhisperRequest;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.converter.BeanOutputConverter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Service
public class WhisperService {

    private final ChatClient chatClient;

    @Value("classpath:prompts/whisper-system.st")
    private Resource whisperSystemPrompt;

    @Value("classpath:prompts/profile-system.st")
    private Resource profileSystemPrompt;

    public WhisperService(ChatClient chatClient) {
        this.chatClient = chatClient;
    }

    public Flux<String> streamNarrative(WhisperRequest request) {
        return chatClient.prompt()
                .system(loadPrompt(whisperSystemPrompt))
                .user(buildUserPrompt(request))
                .stream()
                .content();
    }

    public Mono<CodeProfile> generateProfile(WhisperRequest request) {
        return Mono.fromCallable(() -> {
            var converter = new BeanOutputConverter<>(CodeProfile.class);
            String systemText = loadPrompt(profileSystemPrompt)
                    .replace("{format}", converter.getFormat());
            return chatClient.prompt()
                    .system(systemText)
                    .user(buildProfilePrompt(request))
                    .call()
                    .entity(converter);
        }).subscribeOn(Schedulers.boundedElastic());
    }

    private String loadPrompt(Resource resource) {
        try {
            return resource.getContentAsString(StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load prompt: " + resource.getFilename(), e);
        }
    }

    private String buildUserPrompt(WhisperRequest request) {
        String lang = request.language() != null ? request.language() : "unknown";
        return "Language: " + lang + "\n\n```\n" + request.code() + "\n```";
    }

    private String buildProfilePrompt(WhisperRequest request) {
        String lang = request.language() != null ? request.language() : "unknown";
        return "Analyze this " + lang + " code and return a JSON profile:\n\n```\n" + request.code() + "\n```";
    }
}
