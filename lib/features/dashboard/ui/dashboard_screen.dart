import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../companies/presentation/cubit/company_cubit.dart';
import '../../companies/presentation/cubit/company_state.dart';
import '../../companies/presentation/ui/company_list_screen.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../ai_generator/presentation/ui/generator_screen.dart';
import '../../scheduler/presentation/ui/scheduler_screen.dart';
import '../../analytics/presentation/ui/analytics_screen.dart';
import '../../media/presentation/ui/media_library_screen.dart';
import '../../social_accounts/presentation/ui/social_accounts_screen.dart';
import '../../settings/presentation/ui/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<CompanyCubit>().loadCompanies();
  }

  final List<Widget> _pages = [
    const _DashboardOverview(),
    const GeneratorScreen(),
    const MediaLibraryScreen(),
    const SchedulerScreen(),
    const AnalyticsScreen(),
    const SocialAccountsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        return Scaffold(
          appBar: AppBar(
            title: BlocBuilder<CompanyCubit, CompanyState>(
              builder: (context, state) {
                String title = 'Postly';
                if (state is CompanyLoaded && state.selectedCompany != null) {
                  title = state.selectedCompany!.name;
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CompanyListScreen()),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthCubit>().logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              )
            ],
          ),
          body: isDesktop 
            ? Row(
                children: [
                  _buildSidebar(context),
                  const VerticalDivider(width: 1),
                  Expanded(child: _pages[_currentIndex]),
                ],
              )
            : _pages[_currentIndex],
          bottomNavigationBar: isDesktop ? null : BottomNavigationBar(
            currentIndex: _currentIndex >= 5 ? 0 : _currentIndex, // Cap index for bottom nav
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI Gen'),
              BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Media'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Schedule'),
              BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Stats'),
            ],
          ),
          drawer: isDesktop ? null : Drawer(
            child: _buildSidebar(context),
          ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Postly SaaS', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Management Dashboard', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          _sidebarItem(Icons.dashboard, 'Overview', 0),
          _sidebarItem(Icons.auto_awesome, 'AI Generator', 1),
          _sidebarItem(Icons.photo_library, 'Media Library', 2),
          _sidebarItem(Icons.calendar_month, 'Scheduler', 3),
          _sidebarItem(Icons.analytics, 'Analytics', 4),
          const Divider(),
          _sidebarItem(Icons.share, 'Social Accounts', 5),
          _sidebarItem(Icons.settings, 'Settings', 6),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      onTap: () => setState(() => _currentIndex = index),
    );
  }
}

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryCard(context, 'Scheduled', '12', Icons.schedule, Colors.orange)),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard(context, 'Generated', '45', Icons.auto_awesome, Colors.blue)),
          ],
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(context, 'Connected Accounts', '3', Icons.link, Colors.green),
        const SizedBox(height: 32),
        const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Card(
          child: ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Post published to Facebook'),
            subtitle: Text('2 hours ago'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.auto_awesome, color: Colors.blue),
            title: Text('New AI Post generated'),
            subtitle: Text('5 hours ago'),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String count, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              radius: 20,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
