package com.social.media.services;

import com.social.media.domain.user.User;
import com.social.media.domain.user.dto.LoginUserDto;
import com.social.media.domain.user.dto.RegisterUserDto;
import com.social.media.domain.user.dto.ResponseRegisterUserDto;
import com.social.media.domain.user_profile.dto.UserProfileDto;
import com.social.media.repository.UserRepository;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthenticationService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final UserProfileService userProfileService;

    public AuthenticationService(UserRepository userRepository, PasswordEncoder passwordEncoder, AuthenticationManager authenticationManager, UserProfileService userProfileService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.userProfileService = userProfileService;
    }

    public ResponseRegisterUserDto signup(RegisterUserDto userDto){
        User user = new User(userDto.username(), passwordEncoder.encode(userDto.password()), userDto.email(), userDto.dateOfBirth());
        User createdUser = userRepository.save(user);
        userProfileService.create(createdUser.getUsername(), new UserProfileDto(createdUser.getUsername(), ""));
        return ResponseRegisterUserDto.fromEntity(createdUser);
    }

    public User authenticate(LoginUserDto userDto) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            userDto.username(),
                            userDto.password()
                    )
            );
        } catch (AuthenticationException e) {
            throw new RuntimeException(e);
        }
        return userRepository.findByUsername(userDto.username())
                .orElseThrow();
    }


}
