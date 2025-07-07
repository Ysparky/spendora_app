import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/core/utils/currency_utils.dart';
import 'package:spendora_app/core/services/local_storage_service.dart';
import 'package:spendora_app/core/services/currency_conversion_service.dart';
import 'package:spendora_app/core/utils/icon_utils.dart';
import 'package:spendora_app/core/utils/locale_utils.dart';
import 'package:spendora_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendora_app/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:spendora_app/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:spendora_app/features/transactions/domain/models/transaction.dart';
import 'package:spendora_app/l10n/app_localizations.dart';

const defaultCurrency = CurrencyUtils.defaultCurrency;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardSummary();
    });
  }

  Future<void> _addTransaction(BuildContext context) async {
    final result = await context.push('/transactions/add');
    // Refresh dashboard if transaction was added
    if (result == true && mounted) {
      context.read<DashboardViewModel>().loadDashboardSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
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
                    onPressed: viewModel.loadDashboardSummary,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final summary = viewModel.summary;
          if (summary == null) {
            return Center(child: Text(l10n.noDataAvailable));
          }

          return RefreshIndicator(
            onRefresh: viewModel.loadDashboardSummary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _BalanceCard(summary: summary),
                const SizedBox(height: 16),
                _MonthlyOverviewCard(summary: summary),
                const SizedBox(height: 16),
                if (summary.topCategories.isNotEmpty) ...[
                  _TopCategoriesCard(summary: summary),
                  const SizedBox(height: 16),
                ],
                if (summary.recentTransactions.isNotEmpty)
                  _RecentTransactionsCard(
                    transactions: summary.recentTransactions,
                  ),
                if (summary.topCategories.isEmpty &&
                    summary.recentTransactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Column(
                        children: [
                          Text(
                            l10n.noTransactionsYet,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.addTransactionToStart,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BalanceCard extends StatefulWidget {
  final DashboardSummary summary;

  const _BalanceCard({required this.summary});

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _isExpanded = false;
  bool _isLoading = false;
  String? _conversionDetails;
  double? _totalConverted;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final storage = context.read<LocalStorageService>();
    final isUnifiedView =
        storage.currencyDisplayMode == CurrencyDisplayMode.unified;
    final userCurrency =
        context.read<AuthProvider>().user?.preferences.currency ??
        defaultCurrency;

    if (isUnifiedView && _conversionDetails == null && !_isLoading) {
      _calculateConvertedTotal(userCurrency);
    }
  }

  Future<void> _calculateConvertedTotal(String targetCurrency) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amounts = widget.summary.currencyTotals.map(
        (key, value) => MapEntry(key, value.totalBalance),
      );

      final conversionService = context.read<CurrencyConversionService>();
      final (total, details) = await conversionService
          .getAmountWithConversionDetails(
            amounts: amounts,
            targetCurrency: targetCurrency,
          );

      if (mounted) {
        setState(() {
          _totalConverted = total;
          _conversionDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Schedule the SnackBar for the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  )!.errorCalculatingConversion(e.toString()),
                ),
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final storage = context.watch<LocalStorageService>();
    final isUnifiedView =
        storage.currencyDisplayMode == CurrencyDisplayMode.unified;
    final userCurrency =
        context.read<AuthProvider>().user?.preferences.currency ??
        defaultCurrency;

    return Card(
      child: InkWell(
        onTap: (isUnifiedView && widget.summary.currencyTotals.length > 1)
            ? () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(l10n.totalBalance, style: theme.textTheme.titleMedium),
                  const Spacer(),
                  if (isUnifiedView && widget.summary.currencyTotals.length > 1)
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _isExpanded ? 0.5 : 0,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (isUnifiedView) ...[
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_totalConverted != null) ...[
                  Text(
                    NumberFormat.currency(
                      symbol: CurrencyUtils.getCurrencySymbol(userCurrency),
                    ).format(_totalConverted),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _totalConverted! >= 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                  ),
                  if (_conversionDetails != null && _isExpanded)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _conversionDetails!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                ],
              ] else ...[
                ...widget.summary.currencyTotals.entries.map((entry) {
                  final currency = entry.key;
                  final totals = entry.value;
                  final currencyFormat = NumberFormat.currency(
                    symbol: CurrencyUtils.getCurrencySymbol(currency),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        if (widget.summary.currencyTotals.length > 1) ...[
                          Text(currency, style: theme.textTheme.titleSmall),
                          const SizedBox(width: 16),
                        ],
                        Text(
                          currencyFormat.format(totals.totalBalance),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: totals.totalBalance >= 0
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlyOverviewCard extends StatefulWidget {
  final DashboardSummary summary;

  const _MonthlyOverviewCard({required this.summary});

  @override
  State<_MonthlyOverviewCard> createState() => _MonthlyOverviewCardState();
}

class _MonthlyOverviewCardState extends State<_MonthlyOverviewCard> {
  bool _isExpanded = false;
  bool _isLoading = false;
  Map<String, (double, String)?> _convertedAmounts = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final storage = context.read<LocalStorageService>();
    final isUnifiedView =
        storage.currencyDisplayMode == CurrencyDisplayMode.unified;
    final userCurrency =
        context.read<AuthProvider>().user?.preferences.currency ??
        defaultCurrency;

    if (isUnifiedView && _convertedAmounts.isEmpty && !_isLoading) {
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
      final newAmounts = <String, (double, String)?>{};

      // Convert income and expenses for each currency
      for (final entry in widget.summary.currencyTotals.entries) {
        final currency = entry.key;
        final totals = entry.value;

        // Convert monthly income
        if (totals.monthlyIncome != 0) {
          final (total, details) = await conversionService
              .getAmountWithConversionDetails(
                amounts: {currency: totals.monthlyIncome},
                targetCurrency: targetCurrency,
              );
          newAmounts['income_$currency'] = (total, details);
        }

        // Convert monthly expenses
        if (totals.monthlyExpenses != 0) {
          final (total, details) = await conversionService
              .getAmountWithConversionDetails(
                amounts: {currency: totals.monthlyExpenses},
                targetCurrency: targetCurrency,
              );
          newAmounts['expenses_$currency'] = (total, details);
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
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  )!.errorCalculatingConversion(e.toString()),
                ),
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final storage = context.watch<LocalStorageService>();
    final isUnifiedView =
        storage.currencyDisplayMode == CurrencyDisplayMode.unified;
    final userCurrency =
        context.read<AuthProvider>().user?.preferences.currency ??
        defaultCurrency;

    return Card(
      child: InkWell(
        onTap: (isUnifiedView && widget.summary.currencyTotals.length > 1)
            ? () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.monthlyOverview,
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (isUnifiedView && widget.summary.currencyTotals.length > 1)
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _isExpanded ? 0.5 : 0,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (isUnifiedView)
                _buildUnifiedOverview(theme, userCurrency)
              else
                _buildGroupedOverview(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedOverview(ThemeData theme, String currency) {
    final l10n = AppLocalizations.of(context)!;

    // Calculate totals
    double totalIncome = 0;
    double totalExpenses = 0;
    final incomeDetails = <String>[];
    final expensesDetails = <String>[];

    for (final entry in widget.summary.currencyTotals.entries) {
      final currencyCode = entry.key;
      final converted = _convertedAmounts['income_$currencyCode'];
      if (converted != null) {
        totalIncome += converted.$1;
        if (converted.$2.isNotEmpty) {
          incomeDetails.add(converted.$2);
        }
      }

      final expenseConverted = _convertedAmounts['expenses_$currencyCode'];
      if (expenseConverted != null) {
        totalExpenses += expenseConverted.$1;
        if (expenseConverted.$2.isNotEmpty) {
          expensesDetails.add(expenseConverted.$2);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.income,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(
            symbol: CurrencyUtils.getCurrencySymbol(currency),
          ).format(totalIncome),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_isExpanded && incomeDetails.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              incomeDetails.join('\n'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          l10n.expenses,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(
            symbol: CurrencyUtils.getCurrencySymbol(currency),
          ).format(totalExpenses),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_isExpanded && expensesDetails.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              expensesDetails.join('\n'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGroupedOverview(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.summary.currencyTotals.entries.map((entry) {
        final currency = entry.key;
        final totals = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Only show currency label if there's more than one currency
            if (widget.summary.currencyTotals.length > 1)
              Text(
                currency,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (widget.summary.currencyTotals.length > 1)
              const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.income,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(
                          symbol: CurrencyUtils.getCurrencySymbol(currency),
                        ).format(totals.monthlyIncome),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.expenses,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(
                          symbol: CurrencyUtils.getCurrencySymbol(currency),
                        ).format(totals.monthlyExpenses),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}

class _TopCategoriesCard extends StatefulWidget {
  final DashboardSummary summary;

  const _TopCategoriesCard({required this.summary});

  @override
  State<_TopCategoriesCard> createState() => _TopCategoriesCardState();
}

class _TopCategoriesCardState extends State<_TopCategoriesCard> {
  bool _isLoading = false;
  Map<String, (double, String)?> _convertedAmounts = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final storage = context.read<LocalStorageService>();
    final isUnifiedView =
        storage.currencyDisplayMode == CurrencyDisplayMode.unified;
    final userCurrency =
        context.read<AuthProvider>().user?.preferences.currency ??
        defaultCurrency;

    if (isUnifiedView && _convertedAmounts.isEmpty && !_isLoading) {
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
      final newAmounts = <String, (double, String)?>{};

      // Convert amounts for each category
      for (final category in widget.summary.topCategories) {
        final (total, details) = await conversionService
            .getAmountWithConversionDetails(
              amounts: {category.currency: category.amount},
              targetCurrency: targetCurrency,
            );
        newAmounts[category.categoryId] = (total, details);
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
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  )!.errorCalculatingConversion(e.toString()),
                ),
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final storage = context.watch<LocalStorageService>();
    final isUnifiedView =
        storage.currencyDisplayMode == CurrencyDisplayMode.unified;
    final userCurrency =
        context.read<AuthProvider>().user?.preferences.currency ??
        defaultCurrency;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.topCategories, style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.push('/categories'),
                  child: Text(l10n.seeAll),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (isUnifiedView)
              _buildUnifiedCategories(theme, userCurrency)
            else
              _buildGroupedCategories(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedCategories(ThemeData theme, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.summary.topCategories.map((category) {
        final convertedData = _convertedAmounts[category.categoryId];
        if (convertedData == null) return const SizedBox.shrink();

        return InkWell(
          onTap: () => context.push(
            '/transactions',
            extra: {'categoryId': category.categoryId},
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      IconUtils.getIconData(category.icon),
                      size: 24,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                category.getLocalizedName(
                                  context.currentLocaleCode,
                                ),
                                style: theme.textTheme.titleSmall,
                              ),
                              const Spacer(),
                              Text(
                                NumberFormat.currency(
                                  symbol: CurrencyUtils.getCurrencySymbol(
                                    currency,
                                  ),
                                ).format(convertedData.$1),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: category.percentage / 100,
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: .1),
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
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGroupedCategories(ThemeData theme) {
    // Group categories by currency
    final groupedCategories = <String, List<CategorySummary>>{};
    for (final category in widget.summary.topCategories) {
      groupedCategories.putIfAbsent(category.currency, () => []).add(category);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...groupedCategories.entries.map((entry) {
          final currency = entry.key;
          final categories = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Only show currency label if there's more than one currency group
              if (groupedCategories.length > 1) ...[
                Text(
                  currency,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              ...categories.map((category) {
                return InkWell(
                  onTap: () => context.push(
                    '/transactions',
                    extra: {'categoryId': category.categoryId},
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          IconUtils.getIconData(category.icon),
                          size: 24,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    category.getLocalizedName(
                                      context.currentLocaleCode,
                                    ),
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  const Spacer(),
                                  Text(
                                    NumberFormat.currency(
                                      symbol: CurrencyUtils.getCurrencySymbol(
                                        currency,
                                      ),
                                    ).format(category.amount),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: category.percentage / 100,
                                backgroundColor: theme.colorScheme.primary
                                    .withValues(alpha: .1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  final List<TransactionSummary> transactions;

  const _RecentTransactionsCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentTransactions,
                  style: theme.textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => context.push('/transactions'),
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.noDataAvailable,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return ListTile(
                    onTap: () =>
                        context.push('/transactions/details/${transaction.id}'),
                    leading: Icon(
                      IconUtils.getIconData(transaction.categoryIcon),
                      size: 20,
                    ),
                    title: Text(transaction.description),
                    subtitle: Text(DateFormat.yMMMd().format(transaction.date)),
                    trailing: Text(
                      NumberFormat.currency(
                        symbol: CurrencyUtils.getCurrencySymbol(
                          transaction.currency,
                        ),
                      ).format(transaction.amount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color:
                            transaction.type ==
                                TransactionType.income.toString()
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
