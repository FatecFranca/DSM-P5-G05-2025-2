package com.social.media.domain.user.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.LocalDate;

public record ResponseLoginUserDto(
        @JsonProperty("uid")
        String id,
        String email,
        String name,
        LocalDate birthDate) {
}
