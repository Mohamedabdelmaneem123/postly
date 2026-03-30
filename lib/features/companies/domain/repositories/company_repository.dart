import '../entities/company_entity.dart';
import '../entities/company_member_entity.dart';

abstract class CompanyRepository {
  Future<List<CompanyEntity>> getUserCompanies(String userId);
  Future<CompanyEntity> createCompany({
    required String name,
    required String industry,
    required String country,
    required String description,
    required String ownerId,
    String logo = '',
  });
  Future<void> updateCompany(CompanyEntity company);
  Future<void> deleteCompany(String companyId, String ownerId);

  // Multi-tenant team features
  Future<List<CompanyMemberEntity>> getCompanyMembers(String companyId);
  Future<void> inviteTeamMember(String companyId, String userEmail, String role);
  Future<void> updateMemberRole(String companyId, String userId, String newRole);
  Future<void> removeTeamMember(String companyId, String userId);
}
