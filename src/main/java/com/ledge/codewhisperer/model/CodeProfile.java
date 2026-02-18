package com.ledge.codewhisperer.model;

import java.util.List;

public record CodeProfile(
        String codeName,
        String personalityType,
        String currentMood,
        List<String> fears,
        List<String> dreams,
        List<String> quirks,
        String developerNote
) {}
