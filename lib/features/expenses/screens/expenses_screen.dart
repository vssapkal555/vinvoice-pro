import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../providers/expense_providers.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _searchController = TextEditingController();

  String _query = '';
  String _category = 'All';

  static const _categories = <String>[
    'All',
    'Travel',
    'Fuel',
    'Office',
    'Utilities',
    'Rent',
    'Salary',
    'Maintenance',
    'Professional Fees',
    'Marketing',
    'Bank Charges',
    'Tax & Compliance',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _money(int paise) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 2,
    ).format(paise / 100);
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openExpenseForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ExpenseError(
          error: error,
          onRetry: () => ref.invalidate(expensesProvider),
        ),
        data: (expenses) {
          final filtered = _filterExpenses(expenses);

          final total = filtered.fold<int>(
            0,
            (sum, expense) => sum + expense.totalAmountPaise,
          );

          final gst = filtered.fold<int>(
            0,
            (sum, expense) => sum + expense.gstAmountPaise,
          );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(expensesProvider);
              await ref.read(expensesProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                _ExpenseHero(
                  totalExpense: _money(total),
                  gstAmount: _money(gst),
                  expenseCount: filtered.length,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _query = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search expenses',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final selected = category == _category;

                      return FilterChip(
                        selected: selected,
                        label: Text(category),
                        onSelected: (_) {
                          setState(() => _category = category);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Expense Records',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${filtered.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (expenses.isEmpty)
                  const _EmptyExpenses()
                else if (filtered.isEmpty)
                  const _NoMatchingExpenses()
                else
                  ...filtered.map(
                    (expense) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ExpenseCard(
                        expense: expense,
                        money: _money,
                        onEdit: () => _openExpenseForm(expense: expense),
                        onDelete: () => _confirmDelete(expense),
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

  List<Expense> _filterExpenses(List<Expense> expenses) {
    final query = _query.trim().toLowerCase();

    return expenses.where((expense) {
      if (_category != 'All' &&
          expense.category.toLowerCase() != _category.toLowerCase()) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchable = [
        expense.category,
        expense.vendorPayee ?? '',
        expense.description,
        expense.paymentMode ?? '',
        expense.referenceNumber ?? '',
        expense.notes ?? '',
      ].join(' ').toLowerCase();

      return searchable.contains(query);
    }).toList();
  }

  Future<void> _openExpenseForm({Expense? expense}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _ExpenseFormSheet(expense: expense),
    );

    if (result == true) {
      ref.invalidate(expensesProvider);
    }
  }

  Future<void> _confirmDelete(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete expense?'),
          content: Text('Delete "${expense.description}" permanently?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref.read(appDatabaseProvider).deleteExpenseRecord(expense.id);

      ref.invalidate(expensesProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Expense deleted.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete expense: $error')),
      );
    }
  }
}

class _ExpenseHero extends StatelessWidget {
  const _ExpenseHero({
    required this.totalExpense,
    required this.gstAmount,
    required this.expenseCount,
  });

  final String totalExpense;
  final String gstAmount;
  final int expenseCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Expenses',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            totalExpense,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(label: 'Records', value: '$expenseCount'),
              ),
              Expanded(
                child: _HeroMetric(label: 'GST Included', value: gstAmount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.money,
    required this.onEdit,
    required this.onDelete,
  });

  final Expense expense;
  final String Function(int) money;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            expense.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          money(expense.totalAmountPaise),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      [
                        expense.category,
                        if ((expense.vendorPayee ?? '').trim().isNotEmpty)
                          expense.vendorPayee!,
                      ].join(' • '),
                      style: const TextStyle(color: AppTheme.secondaryText),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      DateFormat('dd MMM yyyy').format(expense.expenseDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (expense.gstAmountPaise > 0) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Base ${money(expense.baseAmountPaise)}  •  '
                        'GST ${money(expense.gstAmountPaise)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseFormSheet extends ConsumerStatefulWidget {
  const _ExpenseFormSheet({this.expense});

  final Expense? expense;

  @override
  ConsumerState<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<_ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _expenseDate;
  late String _category;

  late final TextEditingController _vendorController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _baseController;
  late final TextEditingController _gstController;
  late final TextEditingController _paymentModeController;
  late final TextEditingController _referenceController;
  late final TextEditingController _notesController;

  bool _saving = false;

  static const _categories = <String>[
    'Travel',
    'Fuel',
    'Office',
    'Utilities',
    'Rent',
    'Salary',
    'Maintenance',
    'Professional Fees',
    'Marketing',
    'Bank Charges',
    'Tax & Compliance',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    final expense = widget.expense;

    _expenseDate = expense?.expenseDate ?? DateTime.now();
    _category = expense?.category ?? 'Other';

    _vendorController = TextEditingController(text: expense?.vendorPayee ?? '');

    _descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );

    _baseController = TextEditingController(
      text: expense == null
          ? ''
          : (expense.baseAmountPaise / 100).toStringAsFixed(2),
    );

    _gstController = TextEditingController(
      text: expense == null
          ? ''
          : (expense.gstAmountPaise / 100).toStringAsFixed(2),
    );

    _paymentModeController = TextEditingController(
      text: expense?.paymentMode ?? '',
    );

    _referenceController = TextEditingController(
      text: expense?.referenceNumber ?? '',
    );

    _notesController = TextEditingController(text: expense?.notes ?? '');
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _descriptionController.dispose();
    _baseController.dispose();
    _gstController.dispose();
    _paymentModeController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int _toPaise(String value) {
    final amount = double.tryParse(value.trim().replaceAll(',', ''));

    if (amount == null) {
      return 0;
    }

    return (amount * 100).round();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() => _expenseDate = selected);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final company = await ref.read(primaryCompanyProvider.future);

    if (!mounted) {
      return;
    }

    if (company == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please configure your company first.')),
      );

      return;
    }

    final basePaise = _toPaise(_baseController.text);
    final gstPaise = _toPaise(_gstController.text);

    if (basePaise <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base amount must be greater than zero.')),
      );
      return;
    }

    if (gstPaise < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GST amount cannot be negative.')),
      );
      return;
    }

    final totalPaise = basePaise + gstPaise;

    String? nullable(String value) {
      final text = value.trim();
      return text.isEmpty ? null : text;
    }

    setState(() => _saving = true);

    try {
      final db = ref.read(appDatabaseProvider);

      if (widget.expense == null) {
        await db.insertExpenseRecord(
          ExpensesCompanion.insert(
            companyId: company.id,
            expenseDate: _expenseDate,
            category: _category,
            vendorPayee: Value(nullable(_vendorController.text)),
            description: _descriptionController.text.trim(),
            baseAmountPaise: Value(basePaise),
            gstAmountPaise: Value(gstPaise),
            totalAmountPaise: Value(totalPaise),
            paymentMode: Value(nullable(_paymentModeController.text)),
            referenceNumber: Value(nullable(_referenceController.text)),
            notes: Value(nullable(_notesController.text)),
          ),
        );
      } else {
        await db.updateExpenseRecord(
          ExpensesCompanion(
            id: Value(widget.expense!.id),
            companyId: Value(company.id),
            expenseDate: Value(_expenseDate),
            category: Value(_category),
            vendorPayee: Value(nullable(_vendorController.text)),
            description: Value(_descriptionController.text.trim()),
            baseAmountPaise: Value(basePaise),
            gstAmountPaise: Value(gstPaise),
            totalAmountPaise: Value(totalPaise),
            paymentMode: Value(nullable(_paymentModeController.text)),
            referenceNumber: Value(nullable(_referenceController.text)),
            notes: Value(nullable(_notesController.text)),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      ref.invalidate(expensesProvider);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() => _saving = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save expense: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.expense == null ? 'Add Expense' : 'Edit Expense',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expense Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_expenseDate)),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _vendorController,
                decoration: const InputDecoration(
                  labelText: 'Vendor / Payee',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Description is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _baseController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Base Amount *',
                        prefixText: '\u20B9 ',
                      ),
                      validator: (value) {
                        final amount = double.tryParse(
                          (value ?? '').replaceAll(',', '').trim(),
                        );

                        if (amount == null || amount <= 0) {
                          return 'Enter valid amount.';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _gstController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'GST Amount',
                        prefixText: '\u20B9 ',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _paymentModeController,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                  hintText: 'Cash, UPI, Bank Transfer...',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference Number',
                  prefixIcon: Icon(Icons.tag_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _saving
                        ? 'Saving...'
                        : widget.expense == null
                        ? 'Save Expense'
                        : 'Update Expense',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 54,
            color: AppTheme.secondaryText,
          ),
          SizedBox(height: 12),
          Text(
            'No expenses yet',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          SizedBox(height: 6),
          Text(
            'Add your first business expense.',
            style: TextStyle(color: AppTheme.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _NoMatchingExpenses extends StatelessWidget {
  const _NoMatchingExpenses();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Text(
          'No matching expenses.',
          style: TextStyle(color: AppTheme.secondaryText),
        ),
      ),
    );
  }
}

class _ExpenseError extends StatelessWidget {
  const _ExpenseError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Unable to load expenses',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
