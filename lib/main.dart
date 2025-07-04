import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spendora_app/core/theme/app_theme.dart';
import 'package:spendora_app/di.dart';
import 'package:spendora_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDependencies();
  runApp(const SpendoraApp());
}

class SpendoraApp extends StatelessWidget {
  const SpendoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    return MaterialApp(
      title: 'Spendora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(context),
      darkTheme: AppTheme.dark(context),
      themeMode: brightness == Brightness.light
          ? ThemeMode.light
          : ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spendora'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Text(
          'Welcome to Spendora',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
