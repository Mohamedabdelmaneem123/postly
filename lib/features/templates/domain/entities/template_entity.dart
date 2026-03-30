import 'package:equatable/equatable.dart';

class TemplateEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String category;
  final List<String> tags;

  const TemplateEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [id, title, content, category, tags];
}
