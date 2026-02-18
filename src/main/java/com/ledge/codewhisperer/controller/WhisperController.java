package com.ledge.codewhisperer.controller;

import com.ledge.codewhisperer.model.CodeProfile;
import com.ledge.codewhisperer.model.WhisperRequest;
import com.ledge.codewhisperer.service.WhisperService;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

@RestController
@RequestMapping("/api")
public class WhisperController {

    private final WhisperService whisperService;

    public WhisperController(WhisperService whisperService) {
        this.whisperService = whisperService;
    }

    @PostMapping(value = "/whisper", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> whisper(@Valid @RequestBody WhisperRequest req) {
        return whisperService.streamNarrative(req);
    }

    @PostMapping(value = "/profile", produces = MediaType.APPLICATION_JSON_VALUE)
    public CodeProfile profile(@Valid @RequestBody WhisperRequest req) {
        return whisperService.generateProfile(req);
    }
}
