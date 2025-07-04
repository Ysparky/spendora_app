import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/core/router/router.dart';
import 'package:spendora_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendora_app/features/settings/presentation/viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: viewModel.clearError,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final preferences = viewModel.preferences;
          if (preferences == null) {
            return const Center(child: Text('No preferences found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profile Section
              const _SectionHeader(title: 'Profile'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(
                        context.read<AuthProvider>().user?.name ?? 'Unknown',
                      ),
                      subtitle: Text(
                        context.read<AuthProvider>().user?.email ?? '',
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _showEditProfileDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Preferences Section
              const _SectionHeader(title: 'Preferences'),
              Card(
                child: Column(
                  children: [
                    // Currency
                    ListTile(
                      leading: const Icon(Icons.currency_exchange),
                      title: const Text('Currency'),
                      subtitle: Text(preferences.currency),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showCurrencyPicker(context),
                    ),
                    const Divider(),
                    // Notifications
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Notifications'),
                      subtitle: const Text('Enable push notifications'),
                      value: preferences.notifications,
                      onChanged: viewModel.updateNotifications,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account Section
              const _SectionHeader(title: 'Account'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Sign Out'),
                      onTap: () => _handleSignOut(context),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => _showDeleteAccountDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: context.read<AuthProvider>().user?.name,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<AuthProvider>().updateProfile(
                nameController.text.trim(),
              );
              context.pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final viewModel = context.read<SettingsViewModel>();
    final currencies = viewModel.supportedCurrencies;
    final currentCurrency = viewModel.preferences?.currency;

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final currency = currencies[index];
          final isSelected = currency == currentCurrency;

          return ListTile(
            title: Text(currency),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              viewModel.updateCurrency(currency);
              context.pop();
            },
          );
        },
      ),
    );
  }

  void _handleSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        context.go(AppRouter.login);
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<SettingsViewModel>().deleteAccount();
        if (context.mounted) {
          context.go(AppRouter.login);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting account: $e')));
        }
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
