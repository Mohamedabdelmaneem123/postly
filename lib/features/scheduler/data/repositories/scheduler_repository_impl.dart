import '../../domain/entities/scheduled_post_entity.dart';
import '../../domain/repositories/scheduler_repository.dart';
import '../datasources/scheduler_remote_datasource.dart';

class SchedulerRepositoryImpl implements SchedulerRepository {
  final SchedulerRemoteDataSource _dataSource;

  SchedulerRepositoryImpl(this._dataSource);

  @override
  Future<List<ScheduledPostEntity>> getScheduledPosts(String companyId) {
    return _dataSource.getScheduledPosts(companyId);
  }

  @override
  Future<ScheduledPostEntity> schedulePost({
    required String companyId,
    required String content,
    required List<String> targetPlatforms,
    required DateTime scheduledFor,
    List<String> mediaUrls = const [],
  }) {
    return _dataSource.schedulePost(
      companyId: companyId,
      content: content,
      targetPlatforms: targetPlatforms,
      scheduledFor: scheduledFor,
      mediaUrls: mediaUrls,
    );
  }

  @override
  Future<void> cancelPost(String postId) {
    return _dataSource.cancelPost(postId);
  }
}
