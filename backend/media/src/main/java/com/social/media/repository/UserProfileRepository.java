package com.social.media.repository;

import com.social.media.domain.user_profile.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserProfileRepository extends JpaRepository<UserProfile, Long> {

    @Query("SELECT u FROM UserProfile u WHERE UPPER(u.fullName) LIKE %:keyword%")
    List<UserProfile> findByKeyword(String keyword);
}
