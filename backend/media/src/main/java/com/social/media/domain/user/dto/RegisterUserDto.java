package com.social.media.domain.user.dto;


import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDate;

public record RegisterUserDto(String username,
                              String password,
                              String email,
                              @JsonFormat(pattern = "dd/MM/yyyy")
                              LocalDate dateOfBirth) {
}
