package com.social.media.domain.message.content;

import com.social.media.domain.enums.ContentType;

public class Content {
    private ContentType contentType;
    private String data;

    public ContentType getContentType() {
        return contentType;
    }

    public void setContentType(ContentType contentType) {
        this.contentType = contentType;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }
}
