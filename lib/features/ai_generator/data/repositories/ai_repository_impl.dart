import '../../domain/entities/ai_post_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource _dataSource;

  AiRepositoryImpl(this._dataSource);

  @override
  Future<AiPostEntity> generateContent({
    required String industry,
    required String contentType,
    required String goal,
    required String tone,
    required String language,
  }) {
    return _dataSource.generateContent(
      industry: industry,
      contentType: contentType,
      goal: goal,
      tone: tone,
      language: language,
    );
  }
}
