package com.social.media.exception;

public class UserNotFoundException extends RuntimeException{
    public UserNotFoundException(String username) {
        super("User " + username + " not found");
    }
}
