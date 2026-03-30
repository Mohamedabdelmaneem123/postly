import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final String subscriptionPlan;
  final List<String> companies;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    this.subscriptionPlan = 'FREE',
    this.companies = const [],
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
    String? subscriptionPlan,
    List<String>? companies,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      companies: companies ?? this.companies,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        createdAt,
        subscriptionPlan,
        companies,
      ];
}
