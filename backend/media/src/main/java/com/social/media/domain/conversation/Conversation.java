package com.social.media.domain.conversation;

import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.List;

@Document(collection = "coversations")
public class Conversation {
    @Id
    private String id;
    private List<String> participants;
    private boolean hasMessages;
    private LocalDateTime createdAt;

    public String getId() {
        return id;
    }

    public List<String> getParticipants() {
        return participants;
    }

    public void setParticipants(List<String> participants) {
        this.participants = participants;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public boolean isHasMessages() {
        return hasMessages;
    }

    public void setHasMessages(boolean hasMessages) {
        this.hasMessages = hasMessages;
    }

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
        this.hasMessages = false;
    }
}
