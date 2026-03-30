import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/social_account_entity.dart';

class SocialAccountModel extends SocialAccountEntity {
  const SocialAccountModel({
    required super.id,
    required super.companyId,
    required super.platform,
    required super.accountName,
    required super.profilePictureUrl,
    super.isConnected = true,
    required super.connectedAt,
  });

  factory SocialAccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialAccountModel(
      id: doc.id,
      companyId: data['companyId'] ?? '',
      platform: data['platform'] ?? '',
      accountName: data['accountName'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      isConnected: data['isConnected'] ?? true,
      connectedAt: (data['connectedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'companyId': companyId,
      'platform': platform,
      'accountName': accountName,
      'profilePictureUrl': profilePictureUrl,
      'isConnected': isConnected,
      'connectedAt': Timestamp.fromDate(connectedAt),
    };
  }
}
