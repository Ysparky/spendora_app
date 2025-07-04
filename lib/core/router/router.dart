import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spendora_app/core/services/local_storage_service.dart';
import 'package:spendora_app/di.dart';
import 'package:spendora_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendora_app/features/auth/presentation/views/login_screen.dart';
import 'package:spendora_app/features/auth/presentation/views/register_screen.dart';
import 'package:spendora_app/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:spendora_app/features/settings/presentation/views/settings_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String settings = '/settings';
  static const String home = '/';

  static late final AuthProvider _authProvider;
  static late final GoRouter _router;

  static void initialize(AuthProvider authProvider) {
    debugPrint('AppRouter: Initializing with auth provider');
    _authProvider = authProvider;
    _router = GoRouter(
      initialLocation: login,
      redirect: _handleRedirect,
      refreshListenable: _authProvider,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: onboarding,
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        // Add more routes here for authenticated screens
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Home Screen - Coming Soon')),
          ),
        ),
      ],
    );
    debugPrint('AppRouter: Initialization complete');
  }

  static GoRouter get router => _router;

  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = _authProvider.isAuthenticated;
    final isAuthRoute =
        state.matchedLocation == login || state.matchedLocation == register;
    final isOnboardingRoute = state.matchedLocation == onboarding;
    final hasCompletedOnboarding =
        sl<LocalStorageService>().hasCompletedOnboarding;

    debugPrint('AppRouter: Handling redirect');
    debugPrint('AppRouter: isAuthenticated = $isAuthenticated');
    debugPrint('AppRouter: isAuthRoute = $isAuthRoute');
    debugPrint('AppRouter: isOnboardingRoute = $isOnboardingRoute');
    debugPrint('AppRouter: hasCompletedOnboarding = $hasCompletedOnboarding');

    // If not authenticated and not on an auth route, redirect to login
    if (!isAuthenticated && !isAuthRoute) {
      debugPrint('AppRouter: Redirecting to login');
      return login;
    }

    // If authenticated and on an auth route, redirect to onboarding or home
    if (isAuthenticated && isAuthRoute) {
      if (!hasCompletedOnboarding) {
        debugPrint('AppRouter: Redirecting to onboarding');
        return onboarding;
      }
      debugPrint('AppRouter: Redirecting to home');
      return home;
    }

    // If authenticated and hasn't completed onboarding, redirect to onboarding
    if (isAuthenticated && !hasCompletedOnboarding && !isOnboardingRoute) {
      debugPrint('AppRouter: Redirecting to onboarding');
      return onboarding;
    }

    // If authenticated and completed onboarding but still on onboarding route
    if (isAuthenticated && hasCompletedOnboarding && isOnboardingRoute) {
      debugPrint('AppRouter: Redirecting to home');
      return home;
    }

    debugPrint('AppRouter: No redirect needed');
    return null;
  }
}
