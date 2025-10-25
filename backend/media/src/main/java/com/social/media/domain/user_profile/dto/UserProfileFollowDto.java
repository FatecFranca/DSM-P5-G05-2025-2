package com.social.media.domain.user_profile.dto;
import com.social.media.domain.follow.Follow;

import java.util.HashMap;
import java.util.List;

public record UserProfileFollowDto(
        String uid,
        String email,
        String name,
        String bio,
        byte[] profileImageUrl,
        List<String> followers,
        List<String> following
) {}