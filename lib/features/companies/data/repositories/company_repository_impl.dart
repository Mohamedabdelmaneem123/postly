import '../../domain/entities/company_entity.dart';
import '../../domain/entities/company_member_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource _remoteDataSource;

  CompanyRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CompanyEntity>> getUserCompanies(String userId) {
    return _remoteDataSource.getUserCompanies(userId);
  }

  @override
  Future<CompanyEntity> createCompany({
    required String name,
    required String industry,
    required String country,
    required String description,
    required String ownerId,
    String logo = '',
  }) {
    return _remoteDataSource.createCompany(
      name: name,
      industry: industry,
      country: country,
      description: description,
      ownerId: ownerId,
      logo: logo,
    );
  }

  @override
  Future<void> updateCompany(CompanyEntity company) {
    return _remoteDataSource.updateCompany(company);
  }

  @override
  Future<void> deleteCompany(String companyId, String ownerId) {
    return _remoteDataSource.deleteCompany(companyId, ownerId);
  }

  @override
  Future<List<CompanyMemberEntity>> getCompanyMembers(String companyId) {
    return _remoteDataSource.getCompanyMembers(companyId);
  }

  @override
  Future<void> inviteTeamMember(String companyId, String userEmail, String role) {
    return _remoteDataSource.inviteTeamMember(companyId, userEmail, role);
  }

  @override
  Future<void> removeTeamMember(String companyId, String userId) {
    return _remoteDataSource.removeTeamMember(companyId, userId);
  }

  @override
  Future<void> updateMemberRole(String companyId, String userId, String newRole) {
    return _remoteDataSource.updateMemberRole(companyId, userId, newRole);
  }
}
