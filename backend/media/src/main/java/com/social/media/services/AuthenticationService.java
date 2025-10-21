package com.social.media.services;

import com.social.media.domain.user.User;
import com.social.media.domain.user.dto.LoginUserDto;
import com.social.media.domain.user.dto.RegisterUserDto;
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

    public AuthenticationService(UserRepository userRepository, PasswordEncoder passwordEncoder, AuthenticationManager authenticationManager) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
    }

    public User signup(RegisterUserDto userDto){
        User user = new User(userDto.username(), passwordEncoder.encode(userDto.password()), userDto.email());

        return userRepository.save(user);
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
