package com.social.media.services;

import com.social.media.domain.follow.Follow;
import com.social.media.domain.follow.dto.FollowStatusProjection;
import com.social.media.domain.user.User;
import com.social.media.exception.BadRequestException;
import com.social.media.repository.FollowRepository;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class FollowService {

    private final FollowRepository followRepository;
    private final UserService userService;

    public FollowService(FollowRepository followRepository, UserService userService) {
        this.followRepository = followRepository;
        this.userService = userService;
    }

    public void followUser(Long userFollowingId, String username) {
        Follow follow = this.createFollow(userFollowingId, username);
        if (this.followRepository.existsByFollowerIdAndFollwingId(follow.getFollower().getId(),userFollowingId)) {
            throw new BadRequestException("User follower already exists");
        }
        this.followRepository.save(follow);
    }

    public void unfollowUser(String username, Long userFollowingId) {
        User userFollower = userService.findByUsernameOrThrow(username);
        if (!this.followRepository.existsByFollowerIdAndFollwingId(userFollower.getId(),userFollowingId)) {
            throw new BadRequestException("User follow not exists");
        }
        this.followRepository.unfollow(userFollower.getId(),userFollowingId);
    }

    private Follow createFollow(Long userFollowingId, String username) {
        User userFollower = userService.findByUsernameOrThrow(username);
        User userFollowing = userService.findById(userFollowingId);
        Follow follow = new Follow();
        follow.setFollower(userFollower);
        follow.setFollowing(userFollowing);
        return follow;
    }

    public Map<String, Boolean> followStatus(Long followerId,Long followingId){
        FollowStatusProjection status = this.followRepository.getFollowStatus(followerId, followingId);
        return Map.of(
                "isFollowing", status.getIsFollowing() == 1,
                "isFollower", status.getIsFollower() == 1
        );
    }
}
