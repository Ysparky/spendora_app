import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/core/router/router.dart';
import 'package:spendora_app/core/services/local_storage_service.dart';
import 'package:spendora_app/core/theme/app_theme.dart';
import 'package:spendora_app/core/providers/locale_provider.dart';
import 'package:spendora_app/di.dart';
import 'package:spendora_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendora_app/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:spendora_app/features/auth/presentation/viewmodels/register_viewmodel.dart';
import 'package:spendora_app/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:spendora_app/features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import 'package:spendora_app/features/transactions/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spendora_app/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:spendora_app/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spendora_app/core/services/currency_conversion_service.dart';
import 'package:spendora_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
  );

  await setupDependencies();

  AppRouter.initialize(sl<AuthProvider>());

  runApp(const SpendoraApp());
}

class SpendoraApp extends StatelessWidget {
  const SpendoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<LocalStorageService>()),
        ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => sl<LoginViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<RegisterViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<OnboardingViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<SettingsViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<TransactionViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<DashboardViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<CurrencyConversionService>()),
        ChangeNotifierProvider(create: (_) => sl<LocaleProvider>()),
      ],
      child: Consumer2<LocalStorageService, LocaleProvider>(
        builder: (context, storage, localeProvider, child) =>
            MaterialApp.router(
              title: 'Spendora',
              theme: AppTheme.light(context),
              darkTheme: AppTheme.dark(context),
              themeMode: storage.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              routerConfig: AppRouter.router,
              debugShowCheckedModeBanner: false,

              // Localization support
              locale: localeProvider.locale,
              supportedLocales: LocaleProvider.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ),
      ),
    );
  }
}
