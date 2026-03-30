import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/company_cubit.dart';
import '../cubit/company_state.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'create_company_screen.dart';
import 'team_management_screen.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CompanyCubit>().loadCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Companies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCompanyScreen()));
            },
          ),
        ],
      ),
      body: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          if (state is CompanyLoading || state is CompanyInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CompanyError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is CompanyLoaded) {
            final companies = state.companies;

            if (companies.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.business_center, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No companies found.', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCompanyScreen()));
                      },
                      child: const Text('Create a Company'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                final isSelected = state.selectedCompany?.id == company.id;
                
                // Get the current user auth state to see if owner
                final authState = context.read<AuthCubit>().state;
                final bool isOwner = (authState is AuthAuthenticated) && (company.ownerId == authState.user.id);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                      child: company.logo.isNotEmpty 
                          ? Image.network(company.logo) 
                          : Text(company.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(company.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${company.industry} • ${company.country}'),
                    trailing: isOwner 
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.group),
                              tooltip: 'Manage Team',
                              onPressed: () {
                                context.read<CompanyCubit>().selectCompany(company);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamManagementScreen()));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => context.read<CompanyCubit>().deleteCompany(company.id),
                            ),
                          ],
                        )
                      : null,
                    onTap: () {
                      context.read<CompanyCubit>().selectCompany(company);
                      Navigator.pop(context); // typically called from dashboard app bar
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
