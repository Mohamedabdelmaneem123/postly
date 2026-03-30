import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/template_repository.dart';
import 'templates_state.dart';

class TemplatesCubit extends Cubit<TemplatesState> {
  final TemplateRepository _templateRepository;

  TemplatesCubit(this._templateRepository) : super(TemplatesInitial());

  Future<void> loadTemplates({String? category}) async {
    emit(TemplatesLoading());
    try {
      final categories = await _templateRepository.getCategories();
      final templates = await _templateRepository.getTemplates(category: category);
      emit(TemplatesLoaded(
        templates: templates,
        categories: categories,
        selectedCategory: category,
      ));
    } catch (e) {
      emit(TemplatesError(e.toString()));
    }
  }

  void selectCategory(String? category) {
    if (state is TemplatesLoaded) {
      loadTemplates(category: category);
    }
  }
}
