import 'package:equatable/equatable.dart';

class SubscriptionPlanEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double priceMonth;
  final double priceYear;
  final List<String> features;
  final String stripePriceId;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.priceMonth,
    required this.priceYear,
    required this.features,
    required this.stripePriceId,
  });

  @override
  List<Object?> get props => [id, name, description, priceMonth, priceYear, features, stripePriceId];
}
