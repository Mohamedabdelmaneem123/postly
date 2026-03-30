import '../entities/scheduled_post_entity.dart';

abstract class SchedulerRepository {
  Future<List<ScheduledPostEntity>> getScheduledPosts(String companyId);
  Future<ScheduledPostEntity> schedulePost({
    required String companyId,
    required String content,
    required List<String> targetPlatforms,
    required DateTime scheduledFor,
    List<String> mediaUrls = const [],
  });
  Future<void> cancelPost(String postId);
}
