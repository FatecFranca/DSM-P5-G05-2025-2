package com.social.media.controller;

import com.social.media.domain.enums.MessageStatus;
import com.social.media.domain.message.Message;
import com.social.media.domain.message.content.Content;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.annotation.SendToUser;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;

@Controller
@CrossOrigin()
public class ChatController {

    private final SimpMessagingTemplate messagingTemplate;

    public ChatController(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    @MessageMapping("/privateMessage")
    @SendTo("/topic/messages")
    public Message send(Message msg) {
        System.out.println(msg);

        return msg;
    }

}
