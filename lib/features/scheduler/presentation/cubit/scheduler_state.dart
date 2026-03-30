import 'package:equatable/equatable.dart';
import '../../domain/entities/scheduled_post_entity.dart';

abstract class SchedulerState extends Equatable {
  const SchedulerState();

  @override
  List<Object?> get props => [];
}

class SchedulerInitial extends SchedulerState {}

class SchedulerLoading extends SchedulerState {}

class SchedulerLoaded extends SchedulerState {
  final List<ScheduledPostEntity> posts;

  const SchedulerLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class SchedulerError extends SchedulerState {
  final String message;

  const SchedulerError(this.message);

  @override
  List<Object?> get props => [message];
}

class SchedulerActionSuccess extends SchedulerState {
  final String message;

  const SchedulerActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
