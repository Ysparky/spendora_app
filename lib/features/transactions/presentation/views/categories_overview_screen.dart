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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error calculating conversion: $e')),
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
    final theme = Theme.of(context);
    final storage = context.watch<LocalStorageService>();
    final isUnifiedView =
        storage.currencyDisplayMode == CurrencyDisplayMode.unified;
    final userCurrency =
        context.read<AuthProvider>().user?.preferences.currency ?? 'USD';

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
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
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final categories = viewModel.categories;
            if (categories.isEmpty) {
              return const Center(child: Text('No categories found'));
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
                    '${percentage.toStringAsFixed(1)}% of total expenses',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (convertedData.$2.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        convertedData.$2,
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
    // Group categories by currency
    final groupedCategories = <String, List<(Category, double, double)>>{};

    for (final category in categories) {
      final amounts = viewModel.getCategoryAmountsByCurrency(category.id);
      for (final entry in amounts.entries) {
        final currency = entry.key;
        final amount = entry.value;
        final percentage = viewModel.getCategoryPercentage(category.id);
        groupedCategories.putIfAbsent(currency, () => []).add((
          category,
          amount,
          percentage,
        ));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedCategories.length,
      itemBuilder: (context, index) {
        final currency = groupedCategories.keys.elementAt(index);
        final categories = groupedCategories[currency]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                currency,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
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
                              NumberFormat.currency(
                                symbol: CurrencyUtils.getCurrencySymbol(
                                  currency,
                                ),
                              ).format(amount),
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
                          '${percentage.toStringAsFixed(1)}% of total expenses',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
