package com.social.media.repository;

import com.social.media.domain.like.Like;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface LikeRepository extends JpaRepository<Like, Long> {
    long countByPostId(Long postId);

    Optional<Like> findByUserIdAndPostId(Long userId, Long postId);

    @Transactional
    int deleteByUserIdAndPostId(@Param("userId") Long userId, @Param("postId") Long postId);
}
