import '../entities/template_entity.dart';

abstract class TemplateRepository {
  Future<List<TemplateEntity>> getTemplates({String? category});
  Future<List<String>> getCategories();
}
