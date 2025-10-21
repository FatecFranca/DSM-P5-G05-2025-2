package com.social.media.repository;

import com.social.media.domain.follow.Follow;
import com.social.media.domain.follow.dto.FollowStatusProjection;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.NativeQuery;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface FollowRepository extends JpaRepository<Follow, Long> {

    @Query(value = """
    SELECT 
        CASE WHEN EXISTS (
            SELECT 1
            FROM follows
            WHERE follower_id = :followerId
              AND following_id = :followingId
    ) THEN 1 ELSE 0 END AS isFollowing,
        CASE WHEN EXISTS (
            SELECT 1
            FROM follows
            WHERE follower_id = :followingId
              AND following_id = :followerId
    ) THEN 1 ELSE 0 END AS isFollower;
    """, nativeQuery = true)
    FollowStatusProjection getFollowStatus(@Param("followerId") Long followerId, @Param("followingId") Long followingId);

    @Transactional
    @Modifying
    @Query(value = "DELETE FROM FOLLOWS WHERE FOLLOWER_ID = :followerId AND FOLLOWING_ID = :followingId",
    nativeQuery = true)
    void unfollow(@Param("followerId") Long followerId, @Param("followingId") Long followingId);

    @Query(value = """
    SELECT EXISTS (
        SELECT 1 
        FROM follows
        WHERE follower_id = :followerId
          AND following_id = :followingId
        ) AS exist
    """,
    nativeQuery = true)
    Boolean existsByFollowerIdAndFollwingId(@Param("followerId") Long followerId, @Param("followingId") Long followingId);
}
