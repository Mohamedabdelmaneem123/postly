import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:postly/core/di/locator.dart';
import 'package:postly/features/companies/presentation/cubit/company_cubit.dart';
import 'package:postly/features/companies/presentation/cubit/company_state.dart';
import '../cubit/scheduler_cubit.dart';
import '../cubit/scheduler_state.dart';

class SchedulerScreen extends StatelessWidget {
  const SchedulerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<SchedulerCubit>(),
      child: const SchedulerView(),
    );
  }
}

class SchedulerView extends StatefulWidget {
  const SchedulerView({super.key});

  @override
  State<SchedulerView> createState() => _SchedulerViewState();
}

class _SchedulerViewState extends State<SchedulerView> {
  final _contentController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _syncCompanyContext();
  }

  void _syncCompanyContext() {
    final companyState = context.read<CompanyCubit>().state;
    if (companyState is CompanyLoaded && companyState.selectedCompany != null) {
      context.read<SchedulerCubit>().setCompanyContext(companyState.selectedCompany!.id);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  void _schedule() {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter post content')));
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select date and time')));
      return;
    }

    final scheduledDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    context.read<SchedulerCubit>().schedulePost(
      content: _contentController.text.trim(),
      targetPlatforms: ['Facebook', 'Instagram'], // hardcoded for MVP selection
      scheduledFor: scheduledDate,
      // mediaUrls: [] // Handle media upload here in full version
    );
    
    _contentController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CompanyCubit, CompanyState>(
          listener: (context, state) {
            if (state is CompanyLoaded && state.selectedCompany != null) {
              context.read<SchedulerCubit>().setCompanyContext(state.selectedCompany!.id);
            }
          },
        ),
        BlocListener<SchedulerCubit, SchedulerState>(
          listener: (context, state) {
            if (state is SchedulerActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is SchedulerError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        )
      ],
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Queue'),
                Tab(text: 'Compose'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                   BlocBuilder<SchedulerCubit, SchedulerState>(
                    builder: (context, state) {
                      if (state is SchedulerLoading) return const Center(child: CircularProgressIndicator());
                      if (state is SchedulerLoaded) {
                        if (state.posts.isEmpty) {
                          return const Center(child: Text("No posts scheduled."));
                        }
                        return ListView.builder(
                          itemCount: state.posts.length,
                          itemBuilder: (context, index) {
                            final post = state.posts[index];
                            final status = post.status.toLowerCase();
                            final statusColor = status == 'published' ? Colors.green : (status == 'failed' ? Colors.red : (status == 'publishing' ? Colors.blue : Colors.orange));
                            final statusIcon = status == 'published' ? Icons.check_circle : (status == 'failed' ? Icons.error : (status == 'publishing' ? Icons.sync : Icons.schedule));

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: Icon(statusIcon, color: statusColor),
                                title: Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                                subtitle: Text('${post.targetPlatforms.join(", ")} • ${post.scheduledFor.toString().split('.')[0]}'),
                                trailing: Text(post.status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: Text('Select a company to view queue.'));
                    },
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Schedule New Post', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _contentController,
                          decoration: const InputDecoration(labelText: 'Post Caption', alignLabelWithHint: true),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        Row(
                           children: [
                             Expanded(
                               child: ElevatedButton.icon(
                                  icon: const Icon(Icons.image),
                                  label: const Text('Attach Media'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Firebase Storage Upload Stub')));
                                  },
                               ),
                             ),
                             const SizedBox(width: 16),
                             Expanded(
                               child: ElevatedButton.icon(
                                  icon: const Icon(Icons.schedule),
                                  label: Text(_selectedDate == null ? 'Set Time' : '${_selectedDate!.month}/${_selectedDate!.day} ${_selectedTime!.format(context)}'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Theme.of(context).primaryColor),
                                  onPressed: _pickDateTime,
                               ),
                             )
                           ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _schedule,
                          child: const Text('Schedule Post'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
