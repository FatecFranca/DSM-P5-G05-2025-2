package com.social.media.controller;

import com.social.media.domain.user_profile.dto.UserProfileDto;
import com.social.media.domain.user_profile.dto.UserProfileFollowDto;
import com.social.media.services.FollowService;
import com.social.media.services.UserProfileService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/profile")
public class UserProfileController {

    private final UserProfileService userProfileService;
    private final FollowService followService;

    public UserProfileController(UserProfileService userProfileService, FollowService followService) {
        this.userProfileService = userProfileService;
        this.followService = followService;
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserProfileFollowDto> getUserProfile(
            @PathVariable("id") Long id,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        UserProfileFollowDto user = userProfileService.getUserProfile(userDetails.getUsername(), id);
        return ResponseEntity.ok(user);
    }

    @PostMapping
    public ResponseEntity<UserProfileDto> createUserProfile(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody UserProfileDto dto
            ){
        UserProfileDto userProfile = userProfileService.create(userDetails.getUsername(), dto);
        return ResponseEntity.ok(userProfile);
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserProfileDto> updateUserProfile(
            @PathVariable("id") Long id,
            @RequestBody UserProfileDto dto,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        UserProfileDto userProfile = userProfileService.updateUserProfile(id, dto, userDetails.getUsername());
        return ResponseEntity.ok(userProfile);
    }

    @PostMapping("/{id}/follow")
    public ResponseEntity<?> followUserProfile(
            @PathVariable("id") Long id,
            @AuthenticationPrincipal UserDetails userDetails
    ){
        this.followService.followUser(id, userDetails.getUsername());
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}/unfollow")
    public ResponseEntity<?> unfollowUserProfile(
            @PathVariable("id") Long id,
            @AuthenticationPrincipal UserDetails userDetails
    ){
        this.followService.unfollowUser(userDetails.getUsername(), id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/upload")
    public ResponseEntity<UserProfileDto> uploadUserProfile(@PathVariable Long id,
                                               @RequestParam("file")MultipartFile file) throws IOException {
        UserProfileDto userProfile = userProfileService.updateProfilePicture(file, id);
        return ResponseEntity.ok(userProfile);
    }

    @GetMapping("/{id}/image")
    public ResponseEntity<byte[]> getProfileImage(@PathVariable Long id,
                                                  @AuthenticationPrincipal UserDetails userDetails) {
        UserProfileFollowDto profile = this.userProfileService.getUserProfile(userDetails.getUsername(), id);
        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_PNG)
                .body(profile.profileImageUrl());
    }
}
