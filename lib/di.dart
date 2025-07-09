import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendora_app/core/providers/locale_provider.dart';
import 'package:spendora_app/core/services/local_storage_service.dart';
import 'package:spendora_app/core/services/currency_conversion_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spendora_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:spendora_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:spendora_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:spendora_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendora_app/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:spendora_app/features/auth/presentation/viewmodels/register_viewmodel.dart';
import 'package:spendora_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:spendora_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:spendora_app/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:spendora_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:spendora_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:spendora_app/features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import 'package:spendora_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:spendora_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:spendora_app/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:spendora_app/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:spendora_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:spendora_app/features/transactions/presentation/viewmodels/transaction_viewmodel.dart';

/// Global ServiceLocator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> setupDependencies() async {
  // Services
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => LocalStorageService(sl()));
  sl.registerLazySingleton(() => LocaleProvider(sl()));
  sl.registerLazySingleton(
    () => CurrencyConversionService(
      apiKey: dotenv.env['EXCHANGE_RATE_API_KEY'] ?? '',
    ),
  );

  // Features
  _initializeAuth();
  _initializeOnboarding();
  _initializeSettings();
  _initializeDashboard();
  _initializeTransactions();

  // TODO: Add budgets and reports
  _initializeBudgets();
  _initializeReports();
}

void _initializeAuth() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl()),
  );

  // Providers
  sl.registerLazySingleton<AuthProvider>(
    () => AuthProvider(authRepository: sl()),
  );

  // ViewModels
  sl.registerFactory<LoginViewModel>(() => LoginViewModel(authProvider: sl()));

  sl.registerFactory<RegisterViewModel>(
    () => RegisterViewModel(authProvider: sl()),
  );
}

void _initializeTransactions() {
  // Data sources

  // Repositories
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(),
  );

  // ViewModels
  sl.registerFactory<TransactionViewModel>(
    () => TransactionViewModel(repository: sl()),
  );
}

void _initializeBudgets() {
  // Data sources

  // Repositories

  // ViewModels
  // TODO: Add budget viewmodel
}

void _initializeReports() {
  // Data sources

  // Repositories

  // ViewModels
  // TODO: Add report viewmodel
}

void _initializeSettings() {
  // Repositories
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl());

  // ViewModels
  sl.registerFactory<SettingsViewModel>(
    () => SettingsViewModel(repository: sl(), authProvider: sl()),
  );
}

void _initializeOnboarding() {
  // Repositories
  sl.registerLazySingleton<OnboardingRepository>(
    () =>
        OnboardingRepositoryImpl(localStorage: sl(), settingsRepository: sl()),
  );

  // ViewModels
  sl.registerFactory<OnboardingViewModel>(
    () => OnboardingViewModel(repository: sl()),
  );
}

void _initializeDashboard() {
  // Repositories
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(),
  );

  // ViewModels
  sl.registerFactory<DashboardViewModel>(
    () => DashboardViewModel(repository: sl()),
  );
}
