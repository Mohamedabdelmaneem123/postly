import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_routes.dart';

// Import all screens
import '../../features/auth/presentation/ui/login_screen.dart';
import '../../features/auth/presentation/ui/register_screen.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/ai_generator/presentation/ui/generator_screen.dart';
import '../../features/analytics/presentation/ui/analytics_screen.dart';
import '../../features/billing/presentation/ui/billing_screen.dart';
import '../../features/companies/presentation/ui/company_list_screen.dart';
import '../../features/companies/presentation/ui/create_company_screen.dart';
import '../../features/companies/presentation/ui/team_management_screen.dart';
import '../../features/media/presentation/ui/media_library_screen.dart';
import '../../features/scheduler/presentation/ui/scheduler_screen.dart';
import '../../features/settings/presentation/ui/settings_screen.dart';
import '../../features/social_accounts/presentation/ui/connected_accounts_screen.dart';
import '../../features/social_accounts/presentation/ui/social_accounts_screen.dart';
import '../../features/templates/presentation/ui/templates_screen.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initial:
        return MaterialPageRoute(
          builder: (_) => BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return const DashboardScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case AppRoutes.generator:
        return MaterialPageRoute(builder: (_) => const GeneratorScreen());
      case AppRoutes.analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
      case AppRoutes.billing:
        return MaterialPageRoute(builder: (_) => const BillingScreen());
      case AppRoutes.companyList:
        return MaterialPageRoute(builder: (_) => const CompanyListScreen());
      case AppRoutes.createCompany:
        return MaterialPageRoute(builder: (_) => const CreateCompanyScreen());
      case AppRoutes.teamManagement:
        return MaterialPageRoute(builder: (_) => const TeamManagementScreen());
      case AppRoutes.mediaLibrary:
        return MaterialPageRoute(builder: (_) => const MediaLibraryScreen());
      case AppRoutes.scheduler:
        return MaterialPageRoute(builder: (_) => const SchedulerScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.connectedAccounts:
        return MaterialPageRoute(builder: (_) => const ConnectedAccountsScreen());
      case AppRoutes.socialAccounts:
        return MaterialPageRoute(builder: (_) => const SocialAccountsScreen());
      case AppRoutes.templates:
        return MaterialPageRoute(builder: (_) => const TemplatesScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
