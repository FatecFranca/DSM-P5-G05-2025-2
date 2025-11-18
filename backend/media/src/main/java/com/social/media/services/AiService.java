package com.social.media.services;

import ai.onnxruntime.*;
import com.social.media.repository.LikeRepository;
import com.social.media.repository.UserLogRepository;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AiService {
    private final OrtEnvironment env;
    private final OrtSession session;
    private final UserLogRepository  userLogRepository;
    private final LikeRepository likeRepository;

    public AiService(UserLogRepository userLogRepository, LikeRepository likeRepository) throws OrtException, IOException, URISyntaxException {
        this.userLogRepository = userLogRepository;
        this.likeRepository = likeRepository;
        this.env = OrtEnvironment.getEnvironment();
        Path path = Paths.get(getClass().getClassLoader().getResource("modelo.onnx").toURI());
        this.session = env.createSession(path.toString());
    }
    public Map<String, Object> infer(float[] entrada) throws Exception {
        float[][] data = new float[][]{ entrada };
        OnnxTensor tensor = OnnxTensor.createTensor(env, data);
        Map<String, OnnxTensor> inputs = Map.of("input", tensor);

        try (OrtSession.Result result = session.run(inputs)) {
            String[] labelArr = (String[]) result.get("output_label").get().getValue();
            String label = labelArr[0];

            OnnxValue val = result.get("output_probability").get();
            OnnxSequence seq = (OnnxSequence) val;

            List<?> seqValues = (List<?>) seq.getValue();
            OnnxMap onnxMap = (OnnxMap) seqValues.get(0);

            Map<Object, Object> javaMap = (Map<Object, Object>) onnxMap.getValue();
            Map<String, Float> probs = new HashMap<>();

            for (Map.Entry<Object, Object> entry : javaMap.entrySet()) {
                String key = entry.getKey().toString();
                Float prob = (Float) entry.getValue();
                probs.put(key, prob);
            }

            return Map.of(
                    "classe", label,
                    "probabilidades", probs
            );
        }
    }



    private float mapTempoTela(String tempo) {
        if(tempo == null) return 0f;
        return switch (tempo.toLowerCase()) {
            case "baixo" -> 0f;
            case "medio" -> 1f;
            case "alto" -> 2f;
            default -> 0f;
        };
    }

    public Map<String, Object> predictFromUser(Long userId) throws Exception {
        var params = userLogRepository.aiParamsRequest(userId);
        Integer curtidasHoje = likeRepository.getLikeCountCurrentDate(userId);

        float curtidas = curtidasHoje.floatValue();
        float comentarios = curtidasHoje.floatValue();
        float freqAcesso = (params.get("total_access") != null) ? ((Number) params.get("total_access")).floatValue() : 0f;
        float tempoTela = mapTempoTela((String) params.get("tempo_tela"));

        float[] entrada = new float[] {
                curtidas,
                comentarios,
                tempoTela,
                freqAcesso
        };

        return infer(entrada);
    }
}
