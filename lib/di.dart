import 'package:get_it/get_it.dart';
import 'package:spendora_app/core/services/firebase_service.dart';

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
  sl.registerLazySingleton<FirebaseService>(() => FirebaseService());

  // Utils

  // Repositories
}

void _initializeAuth() {
  // Data sources

  // Repositories

  // Use cases

  // ViewModels
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
