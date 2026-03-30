import 'package:equatable/equatable.dart';
import '../../domain/entities/ai_post_entity.dart';

abstract class AiGeneratorState extends Equatable {
  const AiGeneratorState();

  @override
  List<Object?> get props => [];
}

class AiGeneratorInitial extends AiGeneratorState {}

class AiGeneratorLoading extends AiGeneratorState {}

class AiGeneratorSuccess extends AiGeneratorState {
  final AiPostEntity post;

  const AiGeneratorSuccess(this.post);

  @override
  List<Object?> get props => [post];
}

class AiGeneratorError extends AiGeneratorState {
  final String message;

  const AiGeneratorError(this.message);

  @override
  List<Object?> get props => [message];
}
