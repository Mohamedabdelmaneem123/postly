import '../entities/ai_post_entity.dart';

abstract class AiRepository {
  Future<AiPostEntity> generateContent({
    required String industry,
    required String contentType,
    required String goal,
    required String tone,
    required String language,
  });
}
