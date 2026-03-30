import 'package:equatable/equatable.dart';

class CompanyMemberEntity extends Equatable {
  final String userId;
  final String companyId;
  final String role; // 'owner', 'admin', 'editor', 'viewer'

  const CompanyMemberEntity({
    required this.userId,
    required this.companyId,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, companyId, role];
}
