import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/company_cubit.dart';
import '../cubit/company_state.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  final _emailController = TextEditingController();
  String _selectedRole = 'Editor';

  @override
  void initState() {
    super.initState();
    final state = context.read<CompanyCubit>().state;
    if (state is CompanyLoaded && state.selectedCompany != null) {
      context.read<CompanyCubit>().loadCompanyMembers(state.selectedCompany!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Members')),
      body: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          if (state is! CompanyLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final company = state.selectedCompany;
          if (company == null) return const Center(child: Text("No company selected"));

          final members = state.currentMembers ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Invite Member', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(labelText: 'Email Address'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _selectedRole,
                              items: ['Admin', 'Editor', 'Viewer'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                              onChanged: (val) => setState(() => _selectedRole = val!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_emailController.text.isNotEmpty) {
                              context.read<CompanyCubit>().inviteMember(company.id, _emailController.text, _selectedRole);
                              _emailController.clear();
                            }
                          },
                          child: const Text('Invite'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text('User ID: ${member.userId}'), // Better to resolve actual name in prod
                      subtitle: Text(member.role),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                           context.read<CompanyCubit>().removeMember(company.id, member.userId);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
