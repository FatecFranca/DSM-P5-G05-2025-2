package com.social.media.controller;

import com.social.media.domain.posts.comment.Comment;
import com.social.media.domain.posts.comment.dto.CommentCreateDto;
import com.social.media.domain.posts.comment.dto.CommentResponseDto;
import com.social.media.domain.posts.dto.CreatePostDto;
import com.social.media.domain.posts.dto.ResponsePostDto;
import com.social.media.domain.posts.images.dto.PostImagesResponseDto;
import com.social.media.services.CommentService;
import com.social.media.services.LikeService;
import com.social.media.services.PostImageService;
import com.social.media.services.PostService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/posts")
public class PostController {

    private final PostService postService;
    private final LikeService likeService;
    private final PostImageService postImageService;
    private final CommentService commentService;

    public PostController(PostService postService, LikeService likeService, PostImageService postImageService, CommentService commentService) {
        this.postService = postService;
        this.likeService = likeService;
        this.postImageService = postImageService;
        this.commentService = commentService;
    }


    @PostMapping
    public ResponseEntity<ResponsePostDto> createPost(
            @RequestBody CreatePostDto dto,
            @AuthenticationPrincipal UserDetails user
            ){
        ResponsePostDto response = this.postService.create(dto, user.getUsername());
        return ResponseEntity.status(201).body(response);
    }

    @GetMapping
    public ResponseEntity<List<ResponsePostDto>> getPost(
            @AuthenticationPrincipal UserDetails user
    ){
        return ResponseEntity.ok(this.postService.getAllPosts(user.getUsername()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePost(
            @PathVariable("id") Long postId
    ){
        this.postService.delete(postId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/like")
    public ResponseEntity<?> likePost(
            @PathVariable("id") Long postId,
            @AuthenticationPrincipal UserDetails user
    ){
        this.likeService.likePost(postId, user.getUsername());
        return ResponseEntity.status(201).build();
    }

    @DeleteMapping("/{id}/unlike")
    public ResponseEntity<?> unlikePost(
            @PathVariable("id") Long postId,
            @AuthenticationPrincipal UserDetails user
    ){
        return ResponseEntity.ok(this.likeService.unlikePost(user.getUsername(), postId));
    }

    @PostMapping("/{id}/upload")
    public ResponseEntity<List<PostImagesResponseDto>> uploadPostImage(
            @PathVariable("id") Long postId,
            @RequestParam("files") List<MultipartFile> files
    ) throws IOException {
        List<PostImagesResponseDto> images = this.postImageService.saveImage(postId, files);
        return ResponseEntity.ok(images);
    }

    @GetMapping("/{id}/images")
    public ResponseEntity<List<PostImagesResponseDto>> getAllPImages(
            @PathVariable("id") Long postId
    ){
      return ResponseEntity.ok(this.postImageService.getAllImages(postId));
    }

    @GetMapping("/{id}/images/{image_id}")
    public ResponseEntity<byte[]> getImageById(@PathVariable("image_id") Long imageId){
        byte[] image = this.postImageService.getImage(imageId);
        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_PNG)
                .body(image);
    }

    @GetMapping("/{id}/comments")
    public ResponseEntity<List<CommentResponseDto>> getAllComments(@PathVariable("id")  Long postId){
        return ResponseEntity.ok(commentService.getCommentsByPostId(postId));
    }

    @PostMapping("/{id}/comments")
    public ResponseEntity<CommentResponseDto> getComments(@RequestBody CommentCreateDto comment){
        CommentResponseDto response = commentService.createComment(comment);
        return ResponseEntity.status(201).body(response);
    }

    @DeleteMapping("/{id}/comments/{commentId}")
    public ResponseEntity<?> deleteComment(
            @PathVariable("commentId") Long commentId
    ){
        commentService.deleteComment(commentId);
        return ResponseEntity.noContent().build();
    }

}
