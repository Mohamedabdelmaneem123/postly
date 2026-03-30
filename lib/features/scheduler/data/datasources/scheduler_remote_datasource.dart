import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/scheduled_post_entity.dart';

abstract class SchedulerRemoteDataSource {
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

class SchedulerRemoteDataSourceImpl implements SchedulerRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ScheduledPostEntity>> getScheduledPosts(String companyId) async {
    final snapshot = await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('scheduled_posts')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ScheduledPostEntity(
        id: doc.id,
        companyId: companyId,
        content: data['content'] ?? '',
        mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
        targetPlatforms: List<String>.from(data['targetPlatforms'] ?? []),
        scheduledFor: (data['scheduledFor'] as Timestamp).toDate(),
        status: data['status'] ?? 'pending',
      );
    }).toList();
  }

  @override
  Future<ScheduledPostEntity> schedulePost({
    required String companyId,
    required String content,
    required List<String> targetPlatforms,
    required DateTime scheduledFor,
    List<String> mediaUrls = const [],
  }) async {
    final postRef = _firestore
        .collection('companies')
        .doc(companyId)
        .collection('scheduled_posts')
        .doc();

    final post = ScheduledPostEntity(
      id: postRef.id,
      companyId: companyId,
      content: content,
      targetPlatforms: targetPlatforms,
      scheduledFor: scheduledFor,
      mediaUrls: mediaUrls,
    );

    await postRef.set({
      'content': content,
      'targetPlatforms': targetPlatforms,
      'scheduledFor': Timestamp.fromDate(scheduledFor),
      'mediaUrls': mediaUrls,
      'status': 'pending', 
      // Cloud Function logic: A Firestore trigger onCreate on this collection will enqueue a Cloud Task.
      // When the Cloud Task fires at `scheduledFor`, it hits an HTTP Cloud Function which publishes via native API.
    });

    return post;
  }

  @override
  Future<void> cancelPost(String postId) async {
    // Requires company context to traverse subcollection efficiently. 
    // Wait, let's use a CollectionGroup query to find it if we don't know the company,
    // but typically we do. For now, assuming cancellation sets status.
    final snapshot = await _firestore.collectionGroup('scheduled_posts').get();
    for (var doc in snapshot.docs) {
      if (doc.id == postId) {
        await doc.reference.update({'status': 'cancelled'});
        break;
      }
    }
  }
}
