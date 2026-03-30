import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../companies/presentation/cubit/company_cubit.dart';
import '../../../companies/presentation/cubit/company_state.dart';

class ConnectedAccountsScreen extends StatelessWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Social Integrations')),
      body: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          if (state is! CompanyLoaded || state.selectedCompany == null) {
            return const Center(child: Text("Please select a company to manage its social accounts."));
          }

          // Mock data for UI demonstration
          final mockAccounts = [
            {'platform': 'Facebook', 'name': 'Postly Agency', 'connected': true, 'icon': Icons.facebook, 'color': Colors.blue},
            {'platform': 'Twitter / X', 'name': '@postly_app', 'connected': true, 'icon': Icons.close, 'color': Colors.black},
            {'platform': 'LinkedIn', 'name': 'Postly Inc.', 'connected': false, 'icon': Icons.work, 'color': Colors.blue.shade800},
            {'platform': 'Instagram', 'name': 'postly.app', 'connected': false, 'icon': Icons.camera_alt, 'color': Colors.pink},
          ];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mockAccounts.length,
            itemBuilder: (context, index) {
              final acc = mockAccounts[index];
              final isConnected = acc['connected'] as bool;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isConnected ? Colors.green.shade200 : Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: (acc['color'] as Color).withValues(alpha: 0.1),
                    child: Icon(acc['icon'] as IconData, color: acc['color'] as Color),
                  ),
                  title: Text(acc['platform'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(isConnected ? 'Connected as: ${acc['name']}' : 'Not connected'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConnected ? Colors.red.shade50 : Theme.of(context).primaryColor,
                      foregroundColor: isConnected ? Colors.red : Colors.white,
                      elevation: 0,
                    ),
                    onPressed: () {
                      final action = isConnected ? 'Disconnect' : 'Connect';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$action ${acc['platform']} OAuth Flow...')),
                      );
                    },
                    child: Text(isConnected ? 'Disconnect' : 'Connect'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
