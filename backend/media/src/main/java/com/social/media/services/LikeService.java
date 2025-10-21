package com.social.media.services;

import com.social.media.domain.like.Like;
import com.social.media.domain.posts.Post;
import com.social.media.domain.user.User;
import com.social.media.exception.BadRequestException;
import com.social.media.exception.ResourceNotFoundException;
import com.social.media.repository.LikeRepository;
import com.social.media.repository.PostRepository;
import com.social.media.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class LikeService {

    private final LikeRepository likeRepository;
    private final PostRepository postRepository;
    private final UserService userService;

    public LikeService(LikeRepository likeRepository, PostRepository postRepository, UserService userService) {
        this.likeRepository = likeRepository;
        this.postRepository = postRepository;
        this.userService = userService;
    }

    public void likePost(Long postId, String username) {
        User user = userService.findByUsernameOrThrow(username);
        if (likeRepository.findByUserIdAndPostId(user.getId(), postId).isPresent()) {
            throw new BadRequestException("Post already liked");
        }
        Post post = postRepository.findById(postId).orElseThrow(() -> new ResourceNotFoundException("Post not Found"));
        Like like = new Like();
        like.setPost(post);
        like.setUser(user);

        likeRepository.save(like);
    }

    public int unlikePost(String username, Long postId) {
        User user = userService.findByUsernameOrThrow(username);
        if (likeRepository.deleteByUserIdAndPostId(user.getId(), postId) > 0) return 1;
        throw new BadRequestException("Post not liked");
    }

    public long countLikes(Long postId) {
        return likeRepository.countByPostId(postId);
    }

}
