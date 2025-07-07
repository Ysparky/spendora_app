import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/core/router/router.dart';
import 'package:spendora_app/core/services/local_storage_service.dart';
import 'package:spendora_app/core/providers/locale_provider.dart';
import 'package:spendora_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendora_app/features/dashboard/presentation/views/dashboard_screen.dart'
    as CurrencyUtils;
import 'package:spendora_app/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:spendora_app/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          final preferences = viewModel.preferences;
          if (preferences == null) {
            return Center(child: Text(l10n.noPreferencesFound));
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
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profile Section
              _SectionHeader(title: l10n.profile),
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
              _SectionHeader(title: l10n.preferences),
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
                        title: Text(l10n.darkMode),
                        value: storage.isDarkMode,
                        onChanged: (value) async {
                          await storage.setDarkMode(value);
                        },
                      ),
                    ),
                    const Divider(),
                    // Language
                    Consumer<LocaleProvider>(
                      builder: (context, localeProvider, _) => ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(l10n.language),
                        subtitle: Text(
                          localeProvider.getLanguageName(
                            localeProvider.locale?.languageCode ?? 'en',
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showLanguagePicker(context),
                      ),
                    ),
                    const Divider(),
                    // Currency
                    ListTile(
                      leading: const Icon(Icons.currency_exchange),
                      title: Text(l10n.mainCurrency),
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
                    const Divider(),
                    // Currency Display Mode
                    Consumer<LocalStorageService>(
                      builder: (context, storage, _) => ListTile(
                        leading: const Icon(Icons.view_agenda),
                        title: Text(l10n.currencyDisplay),
                        subtitle: Text(
                          storage.currencyDisplayMode ==
                                  CurrencyDisplayMode.unified
                              ? l10n.convertAllTo(preferences.currency)
                              : l10n.groupByCurrency,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showCurrencyDisplayModePicker(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Management Section
              _SectionHeader(title: l10n.dataManagement),
              Card(
                child: Column(
                  children: [
                    // Tags
                    ListTile(
                      leading: const Icon(Icons.tag),
                      title: Text(l10n.manageTags),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {}, // TODO: Navigate to tags management
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account Section
              _SectionHeader(title: l10n.account),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(l10n.signOut),
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
                        title: Text(l10n.advanced),
                        leading: const Icon(Icons.warning_outlined),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.delete_forever),
                            title: Text(l10n.deleteAccount),
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

  void _showCurrencyDisplayModePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storage = context.read<LocalStorageService>();
    final currentMode = storage.currencyDisplayMode;
    final userCurrency =
        context.read<SettingsViewModel>().preferences?.currency ??
        CurrencyUtils.defaultCurrency;

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: [
          ListTile(
            title: Text(l10n.convertAllTo(userCurrency)),
            trailing: currentMode == CurrencyDisplayMode.unified
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              storage.setCurrencyDisplayMode(CurrencyDisplayMode.unified);
              context.pop();
            },
          ),
          ListTile(
            title: Text(l10n.groupByCurrency),
            trailing: currentMode == CurrencyDisplayMode.grouped
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              storage.setCurrencyDisplayMode(CurrencyDisplayMode.grouped);
              context.pop();
            },
          ),
        ],
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
      // Clear local storage before signing out
      await context.read<LocalStorageService>().clearAll();
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        context.go(AppRouter.login);
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountMessage),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorDeletingAccount(e.toString()))),
          );
        }
      }
    }
  }

  void _showLanguagePicker(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    final currentLanguageCode = localeProvider.locale?.languageCode ?? 'en';

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: localeProvider.supportedLanguages.length,
        itemBuilder: (context, index) {
          final language = localeProvider.supportedLanguages[index];
          final isSelected = language['code'] == currentLanguageCode;

          return ListTile(
            title: Text(language['name']!),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              localeProvider.setLocale(Locale(language['code']!));
              context.pop();
            },
          );
        },
      ),
    );
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
  late TextEditingController _nameController;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.editProfile),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.name,
              enabled: !_isLoading,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => context.pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
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
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
