import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Billing & Subscription'),
            subtitle: const Text('Manage your plan and invoices'),
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) =>  BillingScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Team Management'),
            subtitle: const Text('Invite and manage team members'),
            onTap: () {
              // TODO: Navigate to Team
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Postly'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
