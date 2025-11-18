package com.social.media.controller;

import com.social.media.services.AiService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/ai")
public class AiController {

    private final AiService aiService;

    public AiController(AiService aiService) {
        this.aiService = aiService;
    }

    @GetMapping("/predict/{id}")
    public Map<String, Object> ai(@PathVariable Long id) throws Exception {
        return aiService.predictFromUser(id);
    }
}
