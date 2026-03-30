import 'package:equatable/equatable.dart';

class SocialAccountEntity extends Equatable {
  final String id;
  final String companyId;
  final String platform; // e.g. 'Facebook', 'Twitter', 'LinkedIn'
  final String accountName;
  final String profilePictureUrl;
  final bool isConnected;
  final DateTime connectedAt;

  const SocialAccountEntity({
    required this.id,
    required this.companyId,
    required this.platform,
    required this.accountName,
    required this.profilePictureUrl,
    this.isConnected = true,
    required this.connectedAt,
  });

  @override
  List<Object?> get props => [id, companyId, platform, accountName, profilePictureUrl, isConnected, connectedAt];
}
