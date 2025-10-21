package com.social.media.controller;

import com.social.media.domain.jwt.JwtResponse;
import com.social.media.domain.user.User;
import com.social.media.domain.user.dto.LoginUserDto;
import com.social.media.domain.user.dto.RegisterUserDto;
import com.social.media.services.AuthenticationService;
import com.social.media.services.JwtService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {
    private final JwtService jwtService;
    private final AuthenticationService authenticationService;

    public AuthController(JwtService jwtService, AuthenticationService authenticationService) {
        this.jwtService = jwtService;
        this.authenticationService = authenticationService;
    }
    @PostMapping(value = "/signup")
    public ResponseEntity<User> createUser(
            @RequestBody RegisterUserDto userDto
    ) {
        User registeredUser = authenticationService.signup(userDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(registeredUser);
    }

    @PostMapping("/login")
    public ResponseEntity<JwtResponse> authenticate(@RequestBody LoginUserDto userDto) {
        User authenticatedUser = authenticationService.authenticate(userDto);
        String token = jwtService.generateToken(authenticatedUser);
        JwtResponse jwtResponse = new JwtResponse(token, jwtService.getExpiration());
        return ResponseEntity.ok(jwtResponse);
    }

}
