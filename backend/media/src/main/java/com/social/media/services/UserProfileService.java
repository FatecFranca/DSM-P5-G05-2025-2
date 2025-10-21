package com.social.media.services;

import com.social.media.domain.user.User;
import com.social.media.domain.user_profile.UserProfile;
import com.social.media.domain.user_profile.dto.UserProfileDto;
import com.social.media.domain.user_profile.dto.UserProfileFollowDto;
import com.social.media.exception.UserNotAllowedException;
import com.social.media.exception.UserNotFoundException;
import com.social.media.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
public class UserProfileService {

    private final UserProfileRepository userProfileRepository;
    private final UserService userService;
    private final FollowService followService;

    public UserProfileService(UserProfileRepository userProfileRepository, UserService userService, FollowService followService) {
        this.userProfileRepository = userProfileRepository;
        this.userService = userService;
        this.followService = followService;
    }

    public UserProfileDto create(String username, UserProfileDto dto){
        User user = userService.findByUsernameOrThrow(username);
            UserProfile userProfile = this.userProfileRepository.save(new UserProfile(user, dto.bio(), dto.fullname()));
            return this.createDto(userProfile);
    }

    public UserProfileFollowDto getUserProfile(String username, Long id){
        UserProfile userProfile = this.findUserProfileById(id);
        User user = userService.findByUsernameOrThrow(username);
        Map<String, Boolean> followStatus = this.followService.followStatus(id, user.getId());
            return this.createFollowDto(userProfile,followStatus);
    }

    public UserProfileDto updateUserProfile(Long id, UserProfileDto dto, String username){
        UserProfile userProfile = this.findUserProfileById(id);
        if (!username.equals(userProfile.getUser().getUsername())) throw new UserNotAllowedException();
        userProfile.setBio(dto.bio());
        userProfile.setFullName(dto.fullname());

        return this.createDto(userProfileRepository.save(userProfile));
    }

    public UserProfileDto updateProfilePicture(MultipartFile file, Long id) throws IOException {
        UserProfile userProfile = this.findUserProfileById(id);
        userProfile.setProfilePicture(file.getBytes());
        return this.createDto(this.userProfileRepository.save(userProfile));
    }

    private UserProfile findUserProfileById(Long id){
        return this.userProfileRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found"));
    }

    private UserProfileDto createDto(UserProfile userProfile) {
        return new UserProfileDto(userProfile.getFullName(), userProfile.getBio());
    }

    private UserProfileFollowDto createFollowDto(UserProfile userProfile, Map<String, Boolean> followStatus){
        return new UserProfileFollowDto(userProfile.getFullName(), userProfile.getBio(), userProfile.getProfilePicture(), followStatus.get("isFollowing"), followStatus.get("isFollower"));
    }

}
