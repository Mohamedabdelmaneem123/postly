import 'package:equatable/equatable.dart';
import '../../domain/entities/template_entity.dart';

abstract class TemplatesState extends Equatable {
  const TemplatesState();

  @override
  List<Object?> get props => [];
}

class TemplatesInitial extends TemplatesState {}

class TemplatesLoading extends TemplatesState {}

class TemplatesLoaded extends TemplatesState {
  final List<TemplateEntity> templates;
  final List<String> categories;
  final String? selectedCategory;

  const TemplatesLoaded({
    required this.templates,
    required this.categories,
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [templates, categories, selectedCategory];
}

class TemplatesError extends TemplatesState {
  final String message;

  const TemplatesError(this.message);

  @override
  List<Object?> get props => [message];
}
