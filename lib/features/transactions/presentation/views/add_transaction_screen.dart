import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendora_app/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:spendora_app/features/transactions/domain/models/transaction.dart';
import 'package:spendora_app/features/transactions/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spendora_app/l10n/app_localizations.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  RecurringType? _recurringType;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    // Initialize with user's preferred currency
    _selectedCurrency =
        context.read<AuthProvider>().user?.preferences.currency ?? 'USD';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final l10n = AppLocalizations.of(context)!;

    // Only validate category for expense transactions
    if (_type == TransactionType.expense && _selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectCategory)));
      return;
    }

    final transaction = Transaction(
      id: '', // Will be set by Firestore
      amount: amount,
      type: _type,
      categoryId: _selectedCategoryId,
      tags: _tags,
      date: _selectedDate,
      description: _descriptionController.text.trim(),
      isRecurring: _isRecurring,
      recurringType: _isRecurring ? _recurringType : null,
      createdAt: DateTime.now(),
      currency: _selectedCurrency,
    );

    try {
      await context.read<TransactionViewModel>().createTransaction(transaction);
      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorCreatingTransaction)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).languageCode,
    );
    final currencyFormat = NumberFormat.currency(symbol: _selectedCurrency);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addTransaction)),
      body: Consumer<TransactionViewModel>(
        builder: (context, viewModel, child) {
          return Form(
            key: _formKey,
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Transaction Type
                    SegmentedButton<TransactionType>(
                      segments: [
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text(l10n.expense),
                          icon: const Icon(Icons.arrow_downward),
                        ),
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text(l10n.income),
                          icon: const Icon(Icons.arrow_upward),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (Set<TransactionType> selected) {
                        setState(() {
                          _type = selected.first;
                          // Clear category when switching to income
                          if (_type == TransactionType.income) {
                            _selectedCategoryId = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount and Currency
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: TextFormField(
                            controller: _amountController,
                            decoration: InputDecoration(
                              labelText: l10n.amount,
                              prefixText: NumberFormat.currency(
                                symbol: _selectedCurrency,
                                decimalDigits: 0,
                              ).currencySymbol,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.required;
                              }
                              if (double.tryParse(value) == null) {
                                return l10n.invalidAmount;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Consumer<SettingsViewModel>(
                            builder: (context, settingsViewModel, _) {
                              return DropdownButtonFormField<String>(
                                value: _selectedCurrency,
                                decoration: InputDecoration(
                                  labelText: l10n.currency,
                                ),
                                items: settingsViewModel.supportedCurrencies
                                    .map(
                                      (currency) => DropdownMenuItem(
                                        value: currency,
                                        child: Text(currency),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCurrency = value;
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: l10n.description),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.required;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category
                    if (_type == TransactionType.expense)
                      if (viewModel.isCategoriesLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (viewModel.error != null)
                        Text(
                          l10n.errorLoadingCategories(viewModel.error!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: InputDecoration(labelText: l10n.category),
                          items: viewModel.categories
                              ?.map(
                                (category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Row(
                                    children: [
                                      Text(category.icon),
                                      const SizedBox(width: 8),
                                      Text(category.name),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                        ),
                    const SizedBox(height: 16),

                    // Date
                    ListTile(
                      title: const Text('Date'),
                      subtitle: Text(dateFormat.format(_selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              labelText: 'Add Tag',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTag,
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                onDeleted: () => _removeTag(tag),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    // Recurring Transaction
                    SwitchListTile(
                      title: const Text('Recurring Transaction'),
                      value: _isRecurring,
                      onChanged: (value) {
                        setState(() {
                          _isRecurring = value;
                          if (!value) {
                            _recurringType = null;
                          }
                        });
                      },
                    ),
                    if (_isRecurring) ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<RecurringType>(
                        value: _recurringType,
                        decoration: const InputDecoration(
                          labelText: 'Recurring Type',
                        ),
                        items: RecurringType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type.toString().split('.').last.toUpperCase(),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _recurringType = value;
                          });
                        },
                        validator: (value) {
                          if (_isRecurring && value == null) {
                            return 'Please select a recurring type';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(l10n.save),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
