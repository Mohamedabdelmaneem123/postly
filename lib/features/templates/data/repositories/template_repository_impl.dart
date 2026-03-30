import '../../domain/entities/template_entity.dart';
import '../../domain/repositories/template_repository.dart';
import '../datasources/template_remote_datasource.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final TemplateRemoteDataSource _dataSource;

  TemplateRepositoryImpl(this._dataSource);

  @override
  Future<List<TemplateEntity>> getTemplates({String? category}) {
    return _dataSource.getTemplates(category: category);
  }

  @override
  Future<List<String>> getCategories() {
    return _dataSource.getCategories();
  }
}
