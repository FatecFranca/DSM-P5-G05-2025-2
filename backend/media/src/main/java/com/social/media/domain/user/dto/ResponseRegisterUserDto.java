package com.social.media.domain.user.dto;


import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.social.media.domain.user.User;

import java.time.LocalDate;

public record ResponseRegisterUserDto(
        @JsonProperty("uid")
        String id,
        @JsonProperty("name")
        String username,
        String email,
        @JsonFormat(pattern = "dd/MM/yyyy")
        LocalDate dateOfBirth) {

    public static ResponseRegisterUserDto fromEntity(User user) {
        return new ResponseRegisterUserDto(
                user.getId().toString(),
                user.getUsername(),
                user.getEmail(),
                user.getDateOfBirth()
        );
    }

}

