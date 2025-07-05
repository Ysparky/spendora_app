import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/core/router/router.dart';
import 'package:spendora_app/core/services/local_storage_service.dart';
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
          final preferences = viewModel.preferences;
          if (preferences == null) {
            return const Center(child: Text('No preferences found'));
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

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profile Section
              const _SectionHeader(title: 'Profile'),
              Card(
                child: Column(
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) => ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(authProvider.user?.name ?? 'Unknown'),
                        subtitle: Text(authProvider.user?.email ?? ''),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _showEditProfileDialog(context),
                      ),
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
                    // Theme
                    Consumer<LocalStorageService>(
                      builder: (context, storage, _) => SwitchListTile(
                        secondary: Icon(
                          storage.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                        title: const Text('Dark Mode'),
                        value: storage.isDarkMode,
                        onChanged: (value) async {
                          await storage.setDarkMode(value);
                        },
                      ),
                    ),
                    const Divider(),
                    // Language
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      subtitle: Text(preferences.language.toUpperCase()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {}, // TODO: Implement language selection
                    ),
                    const Divider(),
                    // Currency
                    ListTile(
                      leading: const Icon(Icons.currency_exchange),
                      title: const Text('Main Currency'),
                      subtitle: Text(preferences.currency),
                      trailing: viewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: viewModel.isLoading
                          ? null
                          : () => _showCurrencyPicker(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Management Section
              const _SectionHeader(title: 'Data Management'),
              Card(
                child: Column(
                  children: [
                    // Categories
                    ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: const Text('Manage Categories'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {}, // TODO: Navigate to categories management
                    ),
                    const Divider(),
                    // Tags
                    ListTile(
                      leading: const Icon(Icons.tag),
                      title: const Text('Manage Tags'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {}, // TODO: Navigate to tags management
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
                    Theme(
                      data: Theme.of(context).copyWith(
                        listTileTheme: ListTileThemeData(
                          textColor: Theme.of(context).colorScheme.error,
                          iconColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      child: ExpansionTile(
                        title: const Text('Advanced'),
                        leading: const Icon(Icons.warning_outlined),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.delete_forever),
                            title: const Text('Delete Account'),
                            onTap: () => _showDeleteAccountDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          _EditProfileDialog(authProvider: context.read<AuthProvider>()),
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

class _EditProfileDialog extends StatefulWidget {
  final AuthProvider authProvider;

  const _EditProfileDialog({required this.authProvider});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.authProvider.user?.name,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await widget.authProvider.updateProfile(_nameController.text.trim());
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Name',
          border: OutlineInputBorder(),
        ),
        enabled: !_isLoading,
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => context.pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
