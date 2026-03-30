import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../data/services/ai_usage_tracking.dart';
import 'ai_generator_state.dart';

class AiGeneratorCubit extends Cubit<AiGeneratorState> {
  final AiRepository _aiRepository;
  final AiUsageTracking _usageTracking;

  AiGeneratorCubit(this._aiRepository, this._usageTracking) : super(AiGeneratorInitial());

  Future<void> generatePost({
    required String userId,
    required String companyId,
    required String plan,
    required String industry,
    required String contentType,
    required String goal,
    required String tone,
    required String language,
  }) async {
    emit(AiGeneratorLoading());
    try {
      // 1. Check Usage
      await _usageTracking.checkAndIncrementUsage(userId, companyId, plan);

      // 2. Generate
      final post = await _aiRepository.generateContent(
        industry: industry,
        contentType: contentType,
        goal: goal,
        tone: tone,
        language: language,
      );
      emit(AiGeneratorSuccess(post));
    } catch (e) {
      emit(AiGeneratorError(e.toString()));
    }
  }

  void reset() {
    emit(AiGeneratorInitial());
  }
}
