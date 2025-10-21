package com.social.media.services;

import com.social.media.domain.posts.Post;
import com.social.media.domain.posts.dto.CreatePostDto;
import com.social.media.domain.posts.dto.ResponsePostDto;
import com.social.media.domain.posts.dto.ResponsePostProjection;
import com.social.media.domain.user.User;
import com.social.media.repository.PostRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PostService {

    private final PostRepository postRepository;
    private final UserService userService;


    public PostService(PostRepository postRepository, UserService userService) {
        this.postRepository = postRepository;
        this.userService = userService;
    }

    public ResponsePostDto create(CreatePostDto dto,String username) {
        User user = this.userService.findByUsernameOrThrow(username);
        return this.getPostDto(this.postRepository.save(new Post(dto.text(), dto.imageUrl(), user)));
    }

    public List<ResponsePostDto> getAllPosts(String username) {
        User user = this.userService.findByUsernameOrThrow(username);
        return getListPostDto(this.postRepository.findAllPostsWithLikeCount(user.getId()));
    }

    private ResponsePostDto getPostDto(Post post) {
        return new ResponsePostDto(post.getId(),post.getText(),post.getImageUrl(), post.getCreatedAt(), post.getUser().getId(), 0);
    }

    private List<ResponsePostDto> getListPostDto(List<ResponsePostProjection> posts) {
        return posts.stream().map(
                p -> new ResponsePostDto(
                        p.getId(),
                        p.getText(),
                        p.getImageUrl(),
                        p.getCreatedAt(),
                        p.getUserId(),
                        p.getLikes()
                )
        ).toList();
    }
}
