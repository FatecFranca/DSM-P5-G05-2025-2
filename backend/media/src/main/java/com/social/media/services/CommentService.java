package com.social.media.services;

import com.social.media.domain.posts.comment.Comment;
import com.social.media.domain.posts.comment.dto.CommentCreateDto;
import com.social.media.domain.posts.comment.dto.CommentResponseDto;
import com.social.media.repository.CommentRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class CommentService {

    private final CommentRepository commentRepository;

    public CommentService(CommentRepository commentRepository) {
        this.commentRepository = commentRepository;
    }

    public List<CommentResponseDto> getCommentsByPostId(Long postId){
        List<Comment> comments = commentRepository.getCommentsByPostId(postId);
        return comments.stream().map(CommentResponseDto::toDto).collect(Collectors.toList());
    }
    public CommentResponseDto createComment(CommentCreateDto comment) {
        return CommentResponseDto.toDto(commentRepository.save(CommentCreateDto.toEntity(comment)));
    }

    public void deleteComment(Long id) {
        commentRepository.deleteById(id);
    }

}
