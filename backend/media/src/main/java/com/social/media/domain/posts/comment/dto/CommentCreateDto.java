package com.social.media.domain.posts.comment.dto;

import com.social.media.domain.posts.comment.Comment;

public record CommentCreateDto(Long postId, Long userId, String text)   {
    public static Comment toEntity(CommentCreateDto dto) {
        return new Comment(
                dto.postId,
                dto.userId,
                dto.text
        );
    }
}
