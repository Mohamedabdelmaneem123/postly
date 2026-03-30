import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/locator.dart';
import '../cubit/templates_cubit.dart';
import '../cubit/templates_state.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<TemplatesCubit>()..loadTemplates(),
      child: const TemplatesView(),
    );
  }
}

class TemplatesView extends StatelessWidget {
  const TemplatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemplatesCubit, TemplatesState>(
      builder: (context, state) {
        if (state is TemplatesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TemplatesError) {
          return Center(child: Text(state.message));
        } else if (state is TemplatesLoaded) {
          return Column(
            children: [
              _buildCategoryChips(context, state),
              Expanded(
                child: state.templates.isEmpty 
                    ? const Center(child: Text('No templates found for this category.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: state.templates.length,
                        itemBuilder: (context, index) {
                          final template = state.templates[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(template.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(template.category, style: TextStyle(fontSize: 10, color: Theme.of(context).primaryColor)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: Text(
                                      template.content,
                                      style: TextStyle(color: Colors.grey.shade700),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Using template: ${template.title}')));
                                      },
                                      icon: const Icon(Icons.copy, size: 16),
                                      label: const Text('Use'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildCategoryChips(BuildContext context, TemplatesLoaded state) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: const Text('All'),
              selected: state.selectedCategory == null,
              onSelected: (val) {
                if (val) context.read<TemplatesCubit>().selectCategory(null);
              },
            ),
          ),
          ...state.categories.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: state.selectedCategory == cat,
              onSelected: (val) {
                if (val) context.read<TemplatesCubit>().selectCategory(cat);
              },
            ),
          )),
        ],
      ),
    );
  }
}
