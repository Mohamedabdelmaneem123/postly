import '../../domain/entities/template_entity.dart';

abstract class TemplateRemoteDataSource {
  Future<List<TemplateEntity>> getTemplates({String? category});
  Future<List<String>> getCategories();
}

class TemplateRemoteDataSourceImpl implements TemplateRemoteDataSource {
  // Simulating remote fetch for MVP
  // Eventually this points to a Firestore Global 'templates' collection or similar admin-managed database
  final List<TemplateEntity> _mockTemplates = [
    const TemplateEntity(id: '1', title: 'Product Launch', content: 'We are thrilled to announce [Product]! It features [Features]...', category: 'Announcements'),
    const TemplateEntity(id: '2', title: 'Flash Sale', content: 'Don\'t miss out! Get [Discount] off your next purchase using code [Code].', category: 'Sales'),
    const TemplateEntity(id: '3', title: 'Customer Spotlight', content: 'Meet [Name], our amazing customer who achieved [Result] using our service!', category: 'Community'),
    const TemplateEntity(id: '4', title: 'Holiday Greeting', content: 'Wishing you a joyful [Holiday] from all of us at [Company]!', category: 'Holidays'),
    const TemplateEntity(id: '5', title: 'Weekly Tip', content: 'Did you know? [Tip] can help you improve your [Metric]. Try it out!', category: 'Educational'),
    const TemplateEntity(id: '6', title: 'New Feature', content: 'You asked, we listened! [Feature] is now live and ready to use.', category: 'Announcements'),
  ];

  @override
  Future<List<TemplateEntity>> getTemplates({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (category != null && category.isNotEmpty) {
      return _mockTemplates.where((t) => t.category == category).toList();
    }
    return _mockTemplates;
  }

  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockTemplates.map((t) => t.category).toSet().toList();
  }
}
