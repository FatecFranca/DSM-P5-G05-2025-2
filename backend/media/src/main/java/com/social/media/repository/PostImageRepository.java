package com.social.media.repository;

import com.social.media.domain.posts.Post;
import com.social.media.domain.posts.images.PostImages;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PostImageRepository extends JpaRepository<PostImages, Long> {

    @Transactional
    @Query(value = """
    select  a.id, a.image, a.post_id from posts_images a where post_id = :postId
""",
    nativeQuery = true)
    List<PostImages> findByPostIdAll(@Param("postId")Long postId);
}
