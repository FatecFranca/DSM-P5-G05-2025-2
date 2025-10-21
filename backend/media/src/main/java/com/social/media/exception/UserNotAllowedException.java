package com.social.media.exception;

public class UserNotAllowedException extends RuntimeException {
    public UserNotAllowedException() {
        super("User not Allowed");
    }
}
