import 'package:equatable/equatable.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/entities/company_member_entity.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyLoaded extends CompanyState {
  final List<CompanyEntity> companies;
  final CompanyEntity? selectedCompany;
  final List<CompanyMemberEntity>? currentMembers; // for team management view

  const CompanyLoaded({
    required this.companies,
    this.selectedCompany,
    this.currentMembers,
  });

  CompanyLoaded copyWith({
    List<CompanyEntity>? companies,
    CompanyEntity? selectedCompany,
    List<CompanyMemberEntity>? currentMembers,
  }) {
    return CompanyLoaded(
      companies: companies ?? this.companies,
      // If we pass null explicitly we want it to be null, but copyWith doesn't handle explicit nulls well.
      // For selectedCompany, if not provided we keep old, but we might need a way to clear it.
      // Since it's UI selection, we usually always have one selected if list is not empty.
      selectedCompany: selectedCompany ?? this.selectedCompany,
      currentMembers: currentMembers ?? this.currentMembers,
    );
  }

  @override
  List<Object?> get props => [companies, selectedCompany, currentMembers];
}

class CompanyError extends CompanyState {
  final String message;

  const CompanyError(this.message);

  @override
  List<Object?> get props => [message];
}
