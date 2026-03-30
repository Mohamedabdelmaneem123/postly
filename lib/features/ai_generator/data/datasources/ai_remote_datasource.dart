import 'package:cloud_functions/cloud_functions.dart';
import '../../domain/entities/ai_post_entity.dart';

abstract class AiRemoteDataSource {
  Future<AiPostEntity> generateContent({
    required String industry,
    required String contentType,
    required String goal,
    required String tone,
    required String language,
  });
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  @override
  Future<AiPostEntity> generateContent({
    required String industry,
    required String contentType,
    required String goal,
    required String tone,
    required String language,
  }) async {
    try {
      // In a real environment, this calls the Cloud Function.
      // If the function is not found (not deployed yet), we'll return mock data for testing.
      try {
        final result = await _functions.httpsCallable('generatePost').call({
          'industry': industry,
          'contentType': contentType,
          'goal': goal,
          'tone': tone,
          'language': language,
        });

        final data = result.data as Map<String, dynamic>;
        return AiPostEntity(
          content: data['content'] ?? '',
          contentType: contentType,
          tone: tone,
          language: language,
        );
      } on FirebaseFunctionsException catch (e) {
        if (e.code == 'not-found' || e.code == 'unavailable') {
          // Return mock data so the user can continue testing the UI
          return _getMockContent(industry, contentType, goal, tone, language);
        }
        rethrow;
      }
    } catch (e) {
      // Fallback for any other error (like networking)
      return _getMockContent(industry, contentType, goal, tone, language);
    }
  }

  Future<AiPostEntity> _getMockContent(String industry, String contentType, String goal, String tone, String language) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    String mockContent = "";
    if (language == 'Arabic') {
       mockContent = "[محتوى تجريبي لشركة $industry في مجال $contentType]\n\n"
                     "مرحباً بكم! نحن في 'sportage' نقدم لكم أفضل الخدمات الرياضية في مصر. "
                     "لدينا أحدث الأجهزة ومدربين محترفين لمساعدتكم في الوصول لأهدافكم. "
                     "تفضلوا بزيارتنا قريباً!\n\n"
                     "#جيم #مصر #لياقة_بدنية";
    } else {
       mockContent = "[Mock Content for $industry ($contentType)]\n\n"
                     "Goal: $goal\n\n"
                     "Hey everyone! Check out our new gym 'sportage' in Egypt. "
                     "We've got state-of-the-art equipment and professional trainers ready to help you reach your goals. "
                     "Come visit us soon!\n\n"
                     "#Gym #Egypt #Sportage #Fitness";
    }

    return AiPostEntity(
      content: mockContent,
      contentType: contentType,
      tone: tone,
      language: language,
    );
  }
}
