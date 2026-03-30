import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:postly/core/di/locator.dart';
import 'package:postly/features/companies/presentation/cubit/company_cubit.dart';
import 'package:postly/features/companies/presentation/cubit/company_state.dart';
import 'package:postly/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:postly/features/auth/presentation/cubit/auth_state.dart';
import 'package:postly/features/media/presentation/cubit/media_cubit.dart';
import 'package:postly/features/media/presentation/cubit/media_state.dart';
import 'package:postly/features/scheduler/presentation/cubit/scheduler_cubit.dart';
import 'package:postly/features/scheduler/presentation/cubit/scheduler_state.dart';
import '../cubit/ai_generator_cubit.dart';
import '../cubit/ai_generator_state.dart';

class GeneratorScreen extends StatelessWidget {
  const GeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<AiGeneratorCubit>(),
      child: const GeneratorView(),
    );
  }
}

class GeneratorView extends StatefulWidget {
  const GeneratorView({super.key});

  @override
  State<GeneratorView> createState() => _GeneratorViewState();
}

class _GeneratorViewState extends State<GeneratorView> {
  final _goalController = TextEditingController();
  
  String _selectedContentType = 'Instagram Caption';
  final List<String> _contentTypes = [
    'Instagram Caption', 'Facebook Post', 'Twitter Thread', 'LinkedIn Article', 
    'Email Marketing', 'Product Description', 'Ad Copy'
  ];

  String _selectedTone = 'Professional';
  final List<String> _tones = ['Professional', 'Casual', 'Funny', 'Urgent', 'Inspirational', 'Persuasive'];

  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Arabic'];

  String? _selectedMediaUrl;

  @override
  void initState() {
    super.initState();
    _loadCompanyMedia();
  }

  void _loadCompanyMedia() {
    final companyState = context.read<CompanyCubit>().state;
    if (companyState is CompanyLoaded && companyState.selectedCompany != null) {
      context.read<MediaCubit>().loadCompanyMedia(companyState.selectedCompany!.id);
      context.read<SchedulerCubit>().setCompanyContext(companyState.selectedCompany!.id);
    }
  }

  void _showScheduleDialog(String content) async {
    DateTime? selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay? selectedTime = const TimeOfDay(hour: 10, minute: 0);
    List<String> selectedPlatforms = ['Facebook', 'Instagram'];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Schedule Post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text('Date: ${selectedDate?.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d != null) setDialogState(() => selectedDate = d);
                      },
                    ),
                    ListTile(
                      title: Text('Time: ${selectedTime?.format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (t != null) setDialogState(() => selectedTime = t);
                      },
                    ),
                    const Divider(),
                    const Text('Platforms', style: TextStyle(fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: const Text('Facebook'),
                      value: selectedPlatforms.contains('Facebook'),
                      onChanged: (v) => setDialogState(() => v! ? selectedPlatforms.add('Facebook') : selectedPlatforms.remove('Facebook')),
                    ),
                    CheckboxListTile(
                      title: const Text('Instagram'),
                      value: selectedPlatforms.contains('Instagram'),
                      onChanged: (v) => setDialogState(() => v! ? selectedPlatforms.add('Instagram') : selectedPlatforms.remove('Instagram')),
                    ),
                    CheckboxListTile(
                      title: const Text('TikTok'),
                      value: selectedPlatforms.contains('TikTok'),
                      onChanged: (v) => setDialogState(() => v! ? selectedPlatforms.add('TikTok') : selectedPlatforms.remove('TikTok')),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
              ],
            );
          },
        );
      },
    );

    if (result == true && selectedDate != null && selectedTime != null) {
      final scheduledAt = DateTime(
        selectedDate!.year, selectedDate!.month, selectedDate!.day,
        selectedTime!.hour, selectedTime!.minute,
      );

      if (!mounted) return;
      
      context.read<SchedulerCubit>().schedulePost(
        content: content,
        targetPlatforms: selectedPlatforms,
        scheduledFor: scheduledAt,
        mediaUrls: _selectedMediaUrl != null ? [_selectedMediaUrl!] : [],
      );
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _generatePost() {
    final companyState = context.read<CompanyCubit>().state;
    final authState = context.read<AuthCubit>().state;

    if (companyState is! CompanyLoaded || companyState.selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create and select a company first!')),
      );
      return;
    }

    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User session expired. Please log in again.')),
      );
      return;
    }

    if (_goalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a goal/topic')),
      );
      return;
    }

    context.read<AiGeneratorCubit>().generatePost(
      userId: authState.user.id,
      companyId: companyState.selectedCompany!.id,
      plan: authState.user.subscriptionPlan,
      industry: companyState.selectedCompany!.industry,
      contentType: _selectedContentType,
      goal: _goalController.text.trim(),
      tone: _selectedTone,
      language: _selectedLanguage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiGeneratorCubit, AiGeneratorState>(
      listener: (context, state) {
        if (state is AiGeneratorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Generation failed: ${state.message}')),
          );
        }
      },
      builder: (context, aiState) {
        return BlocListener<SchedulerCubit, SchedulerState>(
          listener: (context, scheduleState) {
            if (scheduleState is SchedulerActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(scheduleState.message), backgroundColor: Colors.green),
              );
              context.read<AiGeneratorCubit>().reset();
              setState(() => _selectedMediaUrl = null);
            } else if (scheduleState is SchedulerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(scheduleState.message), backgroundColor: Colors.red),
              );
            }
          },
          child: _buildBody(aiState),
        );
      },
    );
  }

  Widget _buildBody(AiGeneratorState state) {
    if (state is AiGeneratorLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI is brainstorming...')
          ],
        ),
      );
    }

    if (state is AiGeneratorSuccess) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Generated Output:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy to Clipboard',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: state.post.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard!')),
                    );
                  },
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    state.post.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    textDirection: state.post.language == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  onPressed: _generatePost,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Schedule / Save'),
                  onPressed: () => _showScheduleDialog(state.post.content),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<AiGeneratorCubit>().reset(),
              child: const Text('New Generation Request'),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Generate Social Media Post',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          BlocBuilder<CompanyCubit, CompanyState>(
            builder: (context, companyState) {
              if (companyState is CompanyLoaded && companyState.selectedCompany != null) {
                return Card(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Generating for: ${companyState.selectedCompany!.name} (${companyState.selectedCompany!.industry})',
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
              return const Card(
                color: Colors.orangeAccent,
                child: Padding(
                   padding: EdgeInsets.all(16.0),
                   child: Text('Warning: No company selected! Go to "My Companies" to select one.'),
                )
              );
            },
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _selectedContentType,
            decoration: const InputDecoration(labelText: 'Content Type', prefixIcon: Icon(Icons.article)),
            items: _contentTypes.map((type) => DropdownMenuItem(value: type, child: Text(type, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (value) => setState(() => _selectedContentType = value!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _selectedLanguage,
            decoration: const InputDecoration(labelText: 'Language', prefixIcon: Icon(Icons.language)),
            items: _languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
            onChanged: (value) => setState(() => _selectedLanguage = value!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedTone,
            decoration: const InputDecoration(labelText: 'Tone', prefixIcon: Icon(Icons.record_voice_over)),
            items: _tones.map((tone) => DropdownMenuItem(value: tone, child: Text(tone))).toList(),
            onChanged: (value) => setState(() => _selectedTone = value!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _goalController,
            decoration: const InputDecoration(
              labelText: 'Topic / Goal (e.g., Promote summer menu launch)',
              prefixIcon: Icon(Icons.lightbulb),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          const Text('Attach Media (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: BlocBuilder<MediaCubit, MediaState>(
              builder: (context, mediaState) {
                if (mediaState is MediaLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (mediaState is MediaLoaded) {
                  if (mediaState.mediaFiles.isEmpty) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('Library is empty. Upload in Media tab.', style: TextStyle(fontSize: 12, color: Colors.grey))),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mediaState.mediaFiles.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final media = mediaState.mediaFiles[index];
                      final isSelected = _selectedMediaUrl == media.url;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMediaUrl = isSelected ? null : media.url),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.network(media.url, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Text('Failed to load library');
              },
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Content'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: _generatePost,
          ),
        ],
      ),
    );
  }
}
