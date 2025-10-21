package com.social.media.domain.posts.dto;

import java.time.LocalDateTime;

public interface ResponsePostProjection {
    Long getId();
    String getText();
    String getImageUrl();
    LocalDateTime getCreatedAt();
    Long getUserId();
    long getLikes();
}