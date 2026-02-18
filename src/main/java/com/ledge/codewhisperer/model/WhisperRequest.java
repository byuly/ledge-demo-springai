package com.ledge.codewhisperer.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record WhisperRequest(
        @NotBlank(message = "Code must not be blank")
        @Size(max = 8000, message = "Code must not exceed 8000 characters")
        String code,
        String language
) {}
