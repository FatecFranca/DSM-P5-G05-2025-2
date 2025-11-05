package com.social.media.domain.posts.comment.dto;

import com.social.media.domain.posts.comment.Comment;
import com.social.media.domain.user.User;
import com.social.media.domain.user.dto.ResponseRegisterUserDto;

import java.time.LocalDateTime;

public record CommentResponseDto(String id, String postId, String userId, String userName, String text, LocalDateTime timestamp) {

    public static CommentResponseDto toDto(Comment comment) {
        return new CommentResponseDto(
                comment.getId().toString(),
                comment.getPost().getId().toString(),
                comment.getUser().getId().toString(),
                comment.getUser().getUsername(),
                comment.getText(),
                comment.getTimestamp()
        );
    }

}
