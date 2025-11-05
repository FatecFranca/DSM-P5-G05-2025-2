package com.social.media.domain.posts.dto;

import com.social.media.domain.like.Like;

import java.time.LocalDateTime;
import java.util.List;

public record ResponsePostDto(Long id, String text, String imageUrl, LocalDateTime createdAt, Long userId, List<String> likes) {
}
