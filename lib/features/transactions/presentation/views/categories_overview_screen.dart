import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/core/services/local_storage_service.dart';
import 'package:spendora_app/core/services/currency_conversion_service.dart';
import 'package:spendora_app/core/utils/currency_utils.dart';
import 'package:spendora_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendora_app/features/transactions/domain/models/category.dart';
import 'package:spendora_app/features/transactions/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spendora_app/l10n/app_localizations.dart';

class CategoriesOverviewScreen extends StatefulWidget {
  const CategoriesOverviewScreen({super.key});

  @override
  State<CategoriesOverviewScreen> createState() =>
      _CategoriesOverviewScreenState();
}

class _CategoriesOverviewScreenState extends State<CategoriesOverviewScreen> {
  bool _isLoading = false;
  Map<String, (double, String)?> _convertedAmounts = {};

  Future<void> _initializeData() async {
    final viewModel = context.read<TransactionViewModel>();
    await viewModel.loadTransactions(); // Load transactions first
    await viewModel.loadCategories(); // Then load categories

    // Calculate converted amounts if needed
    final storage = context.read<LocalStorageService>();
    final isUnifiedView =
        storage.currencyDisplayMode == CurrencyDisplayMode.unified;
    final userCurrency =
        context.read<AuthProvider>().user?.preferences.currency ?? 'USD';

    if (isUnifiedView && mounted) {
      await _calculateConvertedAmounts(userCurrency);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final storage = context.read<LocalStorageService>();
    final isUnifiedView =
        storage.currencyDisplayMode == CurrencyDisplayMode.unified;
    final userCurrency =
        context.read<AuthProvider>().user?.preferences.currency ?? 'USD';
    final viewModel = context.read<TransactionViewModel>();

    if (isUnifiedView &&
        !_isLoading &&
        !viewModel.isCategoriesLoading &&
        viewModel.categories.isNotEmpty) {
      _calculateConvertedAmounts(userCurrency);
    }
  }

  Future<void> _calculateConvertedAmounts(String targetCurrency) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final conversionService = context.read<CurrencyConversionService>();
      final viewModel = context.read<TransactionViewModel>();
      final newAmounts = <String, (double, String)?>{};

      // Convert amounts for each category
      for (final category in viewModel.categories) {
        final amounts = viewModel.getCategoryAmountsByCurrency(category.id);
        if (amounts.isNotEmpty) {
          final (total, details) = await conversionService
              .getAmountWithConversionDetails(
                amounts: amounts,
                targetCurrency: targetCurrency,
              );
          newAmounts[category.id] = (total, details);
        }
      }

      if (mounted) {
        setState(() {
          _convertedAmounts = newAmounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.errorCalculatingConversion(e.toString())),
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _refreshData() async {
    final viewModel = context.read<TransactionViewModel>();
    await viewModel.loadTransactions();
    await viewModel.loadCategories();

    final storage = context.read<LocalStorageService>();
    final isUnifiedView =
        storage.currencyDisplayMode == CurrencyDisplayMode.unified;
    final userCurrency =
        context.read<AuthProvider>().user?.preferences.currency ?? 'USD';

    if (isUnifiedView && mounted) {
      await _calculateConvertedAmounts(userCurrency);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final storage = context.watch<LocalStorageService>();
    final isUnifiedView =
        storage.currencyDisplayMode == CurrencyDisplayMode.unified;
    final userCurrency =
        context.read<AuthProvider>().user?.preferences.currency ?? 'USD';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categories)),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer<TransactionViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading || viewModel.isCategoriesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(viewModel.error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }

            final categories = viewModel.categories;
            if (categories.isEmpty) {
              return Center(child: Text(l10n.noCategoriesFound));
            }

            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (isUnifiedView) {
              return _buildUnifiedList(
                theme,
                categories,
                userCurrency,
                viewModel,
              );
            } else {
              return _buildGroupedList(theme, categories, viewModel);
            }
          },
        ),
      ),
    );
  }

  Widget _buildUnifiedList(
    ThemeData theme,
    List<Category> categories,
    String currency,
    TransactionViewModel viewModel,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final convertedData = _convertedAmounts[category.id];
        final percentage = viewModel.getCategoryPercentage(category.id);

        if (convertedData == null) return const SizedBox.shrink();

        return Card(
          child: InkWell(
            onTap: () => context.push(
              '/transactions',
              extra: {'categoryId': category.id},
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(category.icon, style: theme.textTheme.titleLarge),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          category.name,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          symbol: CurrencyUtils.getCurrencySymbol(currency),
                        ).format(convertedData.$1),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.percentageOfTotalExpenses(
                      percentage.toStringAsFixed(1),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (convertedData.$2.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.conversionDetails(convertedData.$2),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupedList(
    ThemeData theme,
    List<Category> categories,
    TransactionViewModel viewModel,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final groupedCategories = <String, List<(Category, double, double)>>{};

    // Group categories by currency
    for (final category in categories) {
      final amounts = viewModel.getCategoryAmountsByCurrency(category.id);
      for (final entry in amounts.entries) {
        final currency = entry.key;
        final amount = entry.value;
        final percentage = viewModel.getCategoryPercentageByCurrency(
          category.id,
          currency,
        );
        groupedCategories.putIfAbsent(currency, () => []);
        groupedCategories[currency]!.add((category, amount, percentage));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedCategories.length,
      itemBuilder: (context, index) {
        final currency = groupedCategories.keys.elementAt(index);
        final categories = groupedCategories[currency]!;
        final currencyFormat = NumberFormat.currency(
          symbol: CurrencyUtils.getCurrencySymbol(currency),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currency,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...categories.map((data) {
              final (category, amount, percentage) = data;
              return Card(
                child: InkWell(
                  onTap: () => context.push(
                    '/transactions',
                    extra: {'categoryId': category.id},
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              category.icon,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                category.name,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              currencyFormat.format(amount),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.1),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.percentageOfTotalExpenses(
                            percentage.toStringAsFixed(1),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
