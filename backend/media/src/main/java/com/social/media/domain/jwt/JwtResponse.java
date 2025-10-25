package com.social.media.domain.jwt;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.LocalDate;

public record JwtResponse(String token, long expiresIn) {
}
