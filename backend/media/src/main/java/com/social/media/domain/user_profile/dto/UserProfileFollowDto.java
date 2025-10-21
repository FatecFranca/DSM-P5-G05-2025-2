package com.social.media.domain.user_profile.dto;

public record UserProfileFollowDto(String fullname, String bio, byte[] profileImageUrl, Boolean isFollowing, Boolean isFollower) {
}