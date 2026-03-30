import 'package:equatable/equatable.dart';

class AiPostEntity extends Equatable {
  final String content;
  final String contentType;
  final String tone;
  final String language;

  const AiPostEntity({
    required this.content,
    required this.contentType,
    required this.tone,
    required this.language,
  });

  @override
  List<Object?> get props => [content, contentType, tone, language];
}
