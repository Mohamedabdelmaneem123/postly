import 'package:equatable/equatable.dart';

class ScheduledPostModel extends Equatable {
  final String id;
  final String companyId;
  final String content;
  final String platform;
  final DateTime scheduledTime;
  final String status; // 'pending', 'published', 'failed'

  const ScheduledPostModel({
    required this.id,
    required this.companyId,
    required this.content,
    required this.platform,
    required this.scheduledTime,
    this.status = 'pending',
  });

  ScheduledPostModel copyWith({
    String? id,
    String? companyId,
    String? content,
    String? platform,
    DateTime? scheduledTime,
    String? status,
  }) {
    return ScheduledPostModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      content: content ?? this.content,
      platform: platform ?? this.platform,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId,
      'content': content,
      'platform': platform,
      'scheduledTime': scheduledTime.toIso8601String(),
      'status': status,
    };
  }

  factory ScheduledPostModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ScheduledPostModel(
      id: documentId,
      companyId: map['companyId'] ?? '',
      content: map['content'] ?? '',
      platform: map['platform'] ?? '',
      scheduledTime: map['scheduledTime'] != null
          ? DateTime.tryParse(map['scheduledTime']) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] ?? 'pending',
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        content,
        platform,
        scheduledTime,
        status,
      ];
}
