import 'package:equatable/equatable.dart';

class TemplateModel extends Equatable {
  final String id;
  final String industry;
  final String title;
  final String content;

  const TemplateModel({
    required this.id,
    required this.industry,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [id, industry, title, content];
}
