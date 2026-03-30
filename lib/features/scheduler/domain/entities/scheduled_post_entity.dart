import 'package:equatable/equatable.dart';

class ScheduledPostEntity extends Equatable {
  final String id;
  final String companyId;
  final String content;
  final String? imageUrl;
  final List<String> mediaUrls;
  final List<String> targetPlatforms;
  final DateTime scheduledFor;
  final String status; // 'draft', 'scheduled', 'published', 'failed'

  const ScheduledPostEntity({
    required this.id,
    required this.companyId,
    required this.content,
    this.imageUrl,
    this.mediaUrls = const [],
    required this.targetPlatforms,
    required this.scheduledFor,
    this.status = 'scheduled',
  });

  @override
  List<Object?> get props => [id, companyId, content, imageUrl, mediaUrls, targetPlatforms, scheduledFor, status];
}
