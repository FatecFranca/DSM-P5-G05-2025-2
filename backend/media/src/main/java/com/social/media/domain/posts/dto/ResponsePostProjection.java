package com.social.media.domain.posts.dto;

import com.social.media.domain.like.Like;

import java.time.LocalDateTime;
import java.util.List;

public interface ResponsePostProjection {
    Long getId();
    String getText();
    String getImageUrl();
    LocalDateTime getCreatedAt();
    Long getUserId();
    List<Like> getLikes();
}