import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/locator.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/app_router.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/companies/presentation/cubit/company_cubit.dart';
import 'features/media/presentation/cubit/media_cubit.dart';
import 'features/scheduler/presentation/cubit/scheduler_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // If you have run 'flutterfire configure', import 'firebase_options.dart' 
  // and use: options: DefaultFirebaseOptions.currentPlatform
  await Firebase.initializeApp();

  await setupLocator();

  runApp(const PostlyApp());
}

class PostlyApp extends StatelessWidget {
  const PostlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => locator<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (_) => locator<CompanyCubit>()),
        BlocProvider(create: (_) => locator<MediaCubit>()),
        BlocProvider(create: (_) => locator<SchedulerCubit>()),
      ],
      child: MaterialApp(
        title: 'Postly',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // Arabic generic RTL support
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar'), // Arabic
          Locale('en'), // English
        ],
        // Forcing Arabic locale for RTL testing based on requirement
        locale: const Locale('ar'), 
        initialRoute: AppRoutes.initial,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
