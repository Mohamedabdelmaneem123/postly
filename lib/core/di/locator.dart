import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// New Auth Architecture
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// New Company Architecture
import '../../features/companies/data/datasources/company_remote_datasource.dart';
import '../../features/companies/data/repositories/company_repository_impl.dart';
import '../../features/companies/domain/repositories/company_repository.dart';
import '../../features/companies/presentation/cubit/company_cubit.dart';

// New AI Generator Architecture
import '../../features/ai_generator/data/datasources/ai_remote_datasource.dart';
import '../../features/ai_generator/data/repositories/ai_repository_impl.dart';
import '../../features/ai_generator/domain/repositories/ai_repository.dart';
import '../../features/ai_generator/presentation/cubit/ai_generator_cubit.dart';
import '../../features/ai_generator/data/services/ai_usage_tracking.dart';

// New Scheduler Architecture
import '../../features/scheduler/data/datasources/scheduler_remote_datasource.dart';
import '../../features/scheduler/data/repositories/scheduler_repository_impl.dart';
import '../../features/scheduler/domain/repositories/scheduler_repository.dart';
import '../../features/scheduler/presentation/cubit/scheduler_cubit.dart';

// New Template Architecture
import '../../features/templates/data/datasources/template_remote_datasource.dart';
import '../../features/templates/data/repositories/template_repository_impl.dart';
import '../../features/templates/domain/repositories/template_repository.dart';
import '../../features/templates/presentation/cubit/templates_cubit.dart';

// New Media Architecture
import '../../features/media/data/datasources/media_remote_datasource.dart';
import '../../features/media/data/repositories/media_repository_impl.dart';
import '../../features/media/domain/repositories/media_repository.dart';
import '../../features/media/presentation/cubit/media_cubit.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Core / Local Storage
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // -- AUTHENTICATION MODULE --
  locator.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(locator<AuthRemoteDataSource>()));
  
  // Auth UseCases
  locator.registerLazySingleton(() => LoginWithEmailUseCase(locator<AuthRepository>()));
  locator.registerLazySingleton(() => RegisterWithEmailUseCase(locator<AuthRepository>()));
  locator.registerLazySingleton(() => LoginWithGoogleUseCase(locator<AuthRepository>()));
  locator.registerLazySingleton(() => LogoutUseCase(locator<AuthRepository>()));
  
  locator.registerLazySingleton(() => AuthCubit(
    authRepository: locator<AuthRepository>(),
    loginWithEmail: locator<LoginWithEmailUseCase>(),
    registerWithEmail: locator<RegisterWithEmailUseCase>(),
    loginWithGoogle: locator<LoginWithGoogleUseCase>(),
    logoutUseCase: locator<LogoutUseCase>(),
  ));

  // -- COMPANY MODULE --
  locator.registerLazySingleton<CompanyRemoteDataSource>(() => CompanyRemoteDataSourceImpl());
  locator.registerLazySingleton<CompanyRepository>(() => CompanyRepositoryImpl(locator<CompanyRemoteDataSource>()));
  locator.registerFactory(() => CompanyCubit(locator<CompanyRepository>(), locator<AuthRepository>()));

  // -- AI GENERATOR MODULE --
  locator.registerLazySingleton<AiRemoteDataSource>(() => AiRemoteDataSourceImpl());
  locator.registerLazySingleton<AiRepository>(() => AiRepositoryImpl(locator<AiRemoteDataSource>()));
  locator.registerLazySingleton(() => AiUsageTracking());
  locator.registerFactory(() => AiGeneratorCubit(locator<AiRepository>(), locator<AiUsageTracking>()));

  // -- SCHEDULER MODULE --
  locator.registerLazySingleton<SchedulerRemoteDataSource>(() => SchedulerRemoteDataSourceImpl());
  locator.registerLazySingleton<SchedulerRepository>(() => SchedulerRepositoryImpl(locator<SchedulerRemoteDataSource>()));
  locator.registerFactory(() => SchedulerCubit(locator<SchedulerRepository>()));

  // -- TEMPLATES MODULE --
  locator.registerLazySingleton<TemplateRemoteDataSource>(() => TemplateRemoteDataSourceImpl());
  locator.registerLazySingleton<TemplateRepository>(() => TemplateRepositoryImpl(locator<TemplateRemoteDataSource>()));
  locator.registerFactory(() => TemplatesCubit(locator<TemplateRepository>()));

  // -- MEDIA MODULE --
  locator.registerLazySingleton<MediaRemoteDataSource>(() => MediaRemoteDataSourceImpl());
  locator.registerLazySingleton<MediaRepository>(() => MediaRepositoryImpl(locator<MediaRemoteDataSource>()));
  locator.registerFactory(() => MediaCubit(locator<MediaRepository>()));
}
