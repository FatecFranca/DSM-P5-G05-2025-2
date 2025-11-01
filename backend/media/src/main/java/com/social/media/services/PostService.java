package com.social.media.services;

import com.social.media.domain.like.Like;
import com.social.media.domain.posts.Post;
import com.social.media.domain.posts.dto.CreatePostDto;
import com.social.media.domain.posts.dto.ResponsePostDto;
import com.social.media.domain.posts.dto.ResponsePostProjection;
import com.social.media.domain.user.User;
import com.social.media.exception.ResourceNotFoundException;
import com.social.media.repository.PostRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PostService {

    private final PostRepository postRepository;
    private final UserService userService;
    private final PostImageService postImageService;


    public PostService(PostRepository postRepository, UserService userService, PostImageService postImageService) {
        this.postRepository = postRepository;
        this.userService = userService;
        this.postImageService = postImageService;
    }

    public ResponsePostDto create(CreatePostDto dto,String username) {
        User user = this.userService.findByUsernameOrThrow(username);
        return this.getPostDto(this.postRepository.save(new Post(dto.text(), dto.imageUrl(), user)));
    }

    public void delete(Long postId) {
        if (!postRepository.existsById(postId)) {
            throw new ResourceNotFoundException("Post not found");
        }
        if (postImageService.getImageCount() >= 1){
            postImageService.deleteAllImages(postId);
        }
        postRepository.deleteById(postId);
    }

    public List<ResponsePostDto> getAllPosts(String username) {
        User user = this.userService.findByUsernameOrThrow(username);
        List<Post> posts = postRepository.findAll();

        return posts.stream().map(post -> {
            List<String> likeIds = post.getLikes().stream()
                    .map(like -> like.getUser().getId().toString())
                    .toList();

            return new ResponsePostDto(
                    post.getId(),
                    post.getText(),
                    post.getImageUrl(),
                    post.getCreatedAt(),
                    post.getUser().getId(),
                    likeIds
            );
        }).toList();
    }

    private ResponsePostDto getPostDto(Post post) {
        return new ResponsePostDto(post.getId(),post.getText(),post.getImageUrl(), post.getCreatedAt(), post.getUser().getId(), null);
    }
}
