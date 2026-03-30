import 'package:equatable/equatable.dart';

class MediaFile extends Equatable {
  final String id;
  final String companyId;
  final String userId;
  final String url;
  final String type; // 'image' or 'video'
  final DateTime createdAt;

  const MediaFile({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.url,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, companyId, userId, url, type, createdAt];
}
