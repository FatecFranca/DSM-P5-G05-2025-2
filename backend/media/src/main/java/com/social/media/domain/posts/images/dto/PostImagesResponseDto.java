package com.social.media.domain.posts.images.dto;

import com.social.media.domain.posts.images.PostImages;

public record PostImagesResponseDto(Long id, Long postId, String path) {
    public static PostImagesResponseDto fromEntity(PostImages postImages) {
        return new PostImagesResponseDto(
                postImages.getId(),
                postImages.getPost().getId(),
                "/posts/" + postImages.getPost().getId()+ "/images/" + postImages.getId()
        );
    }
}
