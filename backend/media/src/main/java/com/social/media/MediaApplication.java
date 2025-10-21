package com.social.media;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class MediaApplication {
	public static void main(String[] args) {
		Dotenv dotenv = Dotenv.load();

		System.setProperty("POSTGRES_HOST", dotenv.get("POSTGRES_HOST"));
		System.setProperty("POSTGRES_PORT", dotenv.get("POSTGRES_PORT"));
		System.setProperty("POSTGRES_DB", dotenv.get("POSTGRES_DB"));
		System.setProperty("POSTGRES_USER", dotenv.get("POSTGRES_USER"));
		System.setProperty("POSTGRES_PASS", dotenv.get("POSTGRES_PASS"));

		System.setProperty("MONGO_USER", dotenv.get("MONGO_USER"));
		System.setProperty("MONGO_PASS", dotenv.get("MONGO_PASS"));
		System.setProperty("MONGO_HOST", dotenv.get("MONGO_HOST"));
		System.setProperty("MONGO_PORT", dotenv.get("MONGO_PORT"));
		System.setProperty("MONGO_DB", dotenv.get("MONGO_DB"));

		System.setProperty("JWT_SECRET", dotenv.get("JWT_SECRET"));
		System.setProperty("JWT_EXPIRATION", dotenv.get("JWT_EXPIRATION"));
		SpringApplication.run(MediaApplication.class, args);
	}

}
