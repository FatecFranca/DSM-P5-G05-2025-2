package com.social.media.repository;

import com.social.media.domain.user.log.UserLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Map;
import java.util.Optional;

public interface UserLogRepository extends JpaRepository<UserLog, Long> {

    Optional<UserLog> findTopByUserIdOrderByIdDesc(Long id);

    @Query(value =
            "select \n" +
                    "    min(u.login_date) as first_login,\n" +
                    "    max(u.logout_date) as last_logout,\n" +
                    "    count(*) as total_access,\n" +
                    "    \n" +
                    "    max(u.logout_date) - min(u.login_date) as tempo_total,\n" +
                    "    \n" +
                    "    case \n" +
                    "        when extract(epoch from (max(u.logout_date) - min(u.login_date))) < 3600 \n" +
                    "            then 'baixo'\n" +
                    "        when extract(epoch from (max(u.logout_date) - min(u.login_date))) < 10800 \n" +
                    "            then 'medio'\n" +
                    "        else 'alto'\n" +
                    "    end as tempo_tela\n" +
                    "from user_log u\n" +
                    "where u.user_id = :id\n" +
                    "  and u.login_date is not null\n" +
                    "  and u.logout_date is not null\n" +
                    "group by u.user_id",
    nativeQuery = true)
    Map<String, Object> aiParamsRequest(@Param("id")Long id);

}
