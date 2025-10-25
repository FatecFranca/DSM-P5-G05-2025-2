package com.social.media.domain.user.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record LoginUserDto(
        @JsonProperty("email")
        String username, String password) {
}
