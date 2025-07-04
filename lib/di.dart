import 'package:get_it/get_it.dart';
import 'package:spendora_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:spendora_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:spendora_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:spendora_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendora_app/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:spendora_app/features/auth/presentation/viewmodels/register_viewmodel.dart';

/// Global ServiceLocator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Core
  _initializeCore();

  // Features
  _initializeAuth();
  _initializeTransactions();
  _initializeBudgets();
  _initializeReports();
  _initializeSettings();
}

void _initializeCore() {
  // Services

  // Utils

  // Repositories
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

  // Use cases

  // ViewModels
}

void _initializeBudgets() {
  // Data sources

  // Repositories

  // Use cases

  // ViewModels
}

void _initializeReports() {
  // Data sources

  // Repositories

  // Use cases

  // ViewModels
}

void _initializeSettings() {
  // Data sources

  // Repositories

  // Use cases

  // ViewModels
}
