package com.social.media.domain.user_profile.dto;

import com.social.media.domain.user_profile.UserProfile;

public record SearchUserProfileDto(
        String id,
        String username,
        String email
) {
    public static SearchUserProfileDto toDto(UserProfile user){
        return new SearchUserProfileDto(
                user.getId().toString(),
                user.getUser().getUsername(),
                user.getUser().getEmail()
        );
    }
}
