import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/scheduler_repository.dart';
import 'scheduler_state.dart';

class SchedulerCubit extends Cubit<SchedulerState> {
  final SchedulerRepository _schedulerRepository;
  String? _currentCompanyId;

  SchedulerCubit(this._schedulerRepository) : super(SchedulerInitial());

  void setCompanyContext(String companyId) {
    _currentCompanyId = companyId;
    loadPosts();
  }

  Future<void> loadPosts() async {
    if (_currentCompanyId == null) {
      emit(const SchedulerError("No company selected."));
      return;
    }
    
    emit(SchedulerLoading());
    try {
      final posts = await _schedulerRepository.getScheduledPosts(_currentCompanyId!);
      // Sort by soonest
      posts.sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
      emit(SchedulerLoaded(posts));
    } catch (e) {
      emit(SchedulerError(e.toString()));
    }
  }

  Future<void> schedulePost({
    required String content,
    required List<String> targetPlatforms,
    required DateTime scheduledFor,
    List<String> mediaUrls = const [],
  }) async {
    if (_currentCompanyId == null) {
      emit(const SchedulerError("No company selected."));
      return;
    }

    final currentState = state;
    emit(SchedulerLoading());
    try {
      await _schedulerRepository.schedulePost(
        companyId: _currentCompanyId!,
        content: content,
        targetPlatforms: targetPlatforms,
        scheduledFor: scheduledFor,
        mediaUrls: mediaUrls,
      );
      
      emit(const SchedulerActionSuccess("Post scheduled successfully!"));
      await loadPosts();
    } catch (e) {
      emit(SchedulerError(e.toString()));
      if (currentState is SchedulerLoaded) emit(currentState);
    }
  }
}
