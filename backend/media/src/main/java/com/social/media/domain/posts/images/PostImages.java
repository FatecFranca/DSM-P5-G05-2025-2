package com.social.media.domain.posts.images;

import com.social.media.domain.posts.Post;
import jakarta.persistence.*;

@Entity
@Table(name = "posts_images")
public class PostImages {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    private Post post;

    @Lob
    @Column(nullable = false)
    private byte[] image;

    public Long getId() {
        return id;
    }

    public Post getPost() {
        return post;
    }

    public void setPost(Post post) {
        this.post = post;
    }

    public byte[] getImage() {
        return image;
    }

    public void setImage(byte[] image) {
        this.image = image;
    }
}
