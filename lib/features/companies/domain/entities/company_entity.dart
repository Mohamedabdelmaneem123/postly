import 'package:equatable/equatable.dart';

class CompanyEntity extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String industry;
  final String country;
  final String logo;
  final String description;
  final DateTime createdAt;

  const CompanyEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.industry,
    required this.country,
    this.logo = '',
    required this.description,
    required this.createdAt,
  });

  CompanyEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? industry,
    String? country,
    String? logo,
    String? description,
    DateTime? createdAt,
  }) {
    return CompanyEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      country: country ?? this.country,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        industry,
        country,
        logo,
        description,
        createdAt,
      ];
}
