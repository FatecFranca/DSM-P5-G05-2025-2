package com.social.media.domain.jwt;

public record JwtResponse(String token, long expiresIn) {
}
