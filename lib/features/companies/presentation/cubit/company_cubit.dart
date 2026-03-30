import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/company_entity.dart';
import 'package:postly/features/auth/domain/entities/user_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'company_state.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository _companyRepository;
  final AuthRepository _authRepository;

  CompanyCubit(this._companyRepository, this._authRepository) : super(CompanyInitial());

  Future<UserEntity?> _getAuthenticatedUser() async {
    UserEntity? user = _authRepository.currentUser;
    if (user == null) {
      try {
        // Wait up to 3 seconds for the auth state to initialize
        user = await _authRepository.authStateChanges
            .firstWhere((u) => u != null)
            .timeout(const Duration(seconds: 3));
      } catch (_) {
        return null;
      }
    }
    return user;
  }

  Future<void> loadCompanies() async {
    emit(CompanyLoading());
    
    final user = await _getAuthenticatedUser();
    if (user == null) {
      emit(const CompanyError("User not authenticated. Please log in."));
      return;
    }

    try {
      final companies = await _companyRepository.getUserCompanies(user.id);
      emit(CompanyLoaded(
        companies: companies,
        selectedCompany: companies.isNotEmpty ? companies.first : null,
      ));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  void selectCompany(CompanyEntity company) {
    if (state is CompanyLoaded) {
      emit((state as CompanyLoaded).copyWith(selectedCompany: company));
    }
  }

  Future<void> createCompany({
    required String name,
    required String industry,
    required String country,
    required String description,
    String logo = '',
  }) async {
    final currentState = state;
    emit(CompanyLoading());

    final user = await _getAuthenticatedUser();
    if (user == null) {
      emit(const CompanyError("User session not found. Please log in again."));
      if (currentState is CompanyLoaded) emit(currentState);
      return;
    }

    try {
      final newCompany = await _companyRepository.createCompany(
        name: name,
        industry: industry,
        country: country,
        description: description,
        ownerId: user.id,
        logo: logo,
      );
      
      if (currentState is CompanyLoaded) {
        final updatedList = List<CompanyEntity>.from(currentState.companies)..add(newCompany);
        emit(CompanyLoaded(
          companies: updatedList,
          selectedCompany: newCompany,
        ));
      } else {
        emit(CompanyLoaded(
          companies: [newCompany],
          selectedCompany: newCompany,
        ));
      }
    } catch (e) {
      emit(CompanyError(e.toString()));
      if (currentState is CompanyLoaded) emit(currentState);
    }
  }

  Future<void> deleteCompany(String companyId) async {
    final user = await _getAuthenticatedUser();
    if (user == null) return;

    final currentState = state;
    if (currentState is CompanyLoaded) {
      emit(CompanyLoading());
      try {
        await _companyRepository.deleteCompany(companyId, user.id);
        final updatedList = currentState.companies.where((c) => c.id != companyId).toList();
        final selected = currentState.selectedCompany?.id == companyId
            ? (updatedList.isNotEmpty ? updatedList.first : null)
            : currentState.selectedCompany;
            
        emit(CompanyLoaded(companies: updatedList, selectedCompany: selected));
      } catch (e) {
        emit(CompanyError(e.toString()));
        emit(currentState);
      }
    }
  }

  // --- TEAM MANAGEMENT ---
  Future<void> loadCompanyMembers(String companyId) async {
    final currentState = state;
    if (currentState is CompanyLoaded) {
      try {
        final members = await _companyRepository.getCompanyMembers(companyId);
        emit(currentState.copyWith(currentMembers: members));
      } catch (e) {
        emit(CompanyError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> inviteMember(String companyId, String email, String role) async {
    final currentState = state;
    if (currentState is CompanyLoaded) {
      try {
        await _companyRepository.inviteTeamMember(companyId, email, role);
        await loadCompanyMembers(companyId); // Reload
      } catch (e) {
        emit(CompanyError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> removeMember(String companyId, String userId) async {
    final currentState = state;
    if (currentState is CompanyLoaded) {
      try {
        await _companyRepository.removeTeamMember(companyId, userId);
        await loadCompanyMembers(companyId);
      } catch (e) {
        emit(CompanyError(e.toString()));
        emit(currentState);
      }
    }
  }
}
