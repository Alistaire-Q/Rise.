import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Masih di-keep jika ada sisa penggunaan, tapi ImageFilter sudah dihapus
import '../currency_provider.dart';
import '../repository.dart';
import 'package:rise/models.dart' as m;

class AddTransactionScreen extends StatefulWidget {
  final m.TransactionType? initialType;

  const AddTransactionScreen({Key? key, this.initialType}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late m.TransactionType _type;
  int? _accountId;
  int? _targetAccountId;
  int? _categoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? m.TransactionType.expense;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final repo = Provider.of<Repository>(context, listen: false);
      final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
      
      // Parse input amount
      double inputAmount = double.parse(_amountCtrl.text);
      
      // Konversi ke USD sebelum save
      double amountInUsd = currencyProvider.convertToUsd(inputAmount);

      if (_type == m.TransactionType.transfer) {
        if (_accountId == null) {
          _showSnackBar('Please select source account.');
          return;
        }
        if (_targetAccountId == null) {
          _showSnackBar('Please select destination account.');
          return;
        }
        if (_accountId == _targetAccountId) {
          _showSnackBar('Source and destination must be different.');
          return;
        }

        // Validate sufficient balance
        final sourceAccount = repo.getAccountById(_accountId!);
        if (sourceAccount == null || sourceAccount.balance < amountInUsd) {
          _showSnackBar('Insufficient balance in source account.');
          return;
        }

        // Execute atomic transfer
        final transferSuccess = await repo.executeAtomicTransfer(
          sourceAccountId: _accountId!,
          destinationAccountId: _targetAccountId!,
          amount: amountInUsd,
        );

        if (!transferSuccess) {
          _showSnackBar('Transfer failed. Please try again.');
          return;
        }
      } else {
        // Income or Expense
        if (_categoryId == null) {
          _showSnackBar('Please select a category.');
          return;
        }
        if (_accountId == null) {
          _showSnackBar('Please select an account.');
          return;
        }

        // Update account balance for income/expense
        final account = repo.getAccountById(_accountId!);
        if (account != null) {
          double newBalance = account.balance;
          if (_type == m.TransactionType.income) {
            newBalance += amountInUsd; // Add income
          } else if (_type == m.TransactionType.expense) {
            if (account.balance < amountInUsd) {
              _showSnackBar('Insufficient balance for this expense.');
              return;
            }
            newBalance -= amountInUsd; // Subtract expense
          }
          await repo.updateAccountBalance(_accountId!, newBalance);
        }
      }

      final t = m.MoneyTransaction(
        amount: amountInUsd,
        type: _type,
        accountId: _accountId!,
        targetAccountId: _targetAccountId,
        categoryId: _categoryId,
        date: _selectedDate,
        notes: _notesCtrl.text,
      );
      await repo.addTransaction(t);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<String> _getCategories(Repository repo) {
    if (_type == m.TransactionType.expense) {
      return m.PredefinedData.expenseCategories;
    } else if (_type == m.TransactionType.income) {
      return m.PredefinedData.incomeCategories;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<Repository>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final theme = Theme.of(context);
    final categories = _getCategories(repo);

    final categoryOptions = _type == m.TransactionType.transfer
        ? [m.Category(id: 1, name: 'Between Accounts', icon: null)] 
        : repo.categories.where((c) => categories.contains(c.name)).toList();

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent, // Background dialog transparan, konten diatur Container
      // FIX: Menghapus properti filter yang menyebabkan error
      
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, // UBAH: Menjadi Putih Polos
            borderRadius: BorderRadius.circular(20),
            // Border tipis abu-abu agar rapi di background putih
            border: Border.all(color: Colors.grey.withOpacity(0.2)), 
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header and Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _type == m.TransactionType.expense
                              ? 'Add Expense'
                              : _type == m.TransactionType.income
                                  ? 'Add Income'
                                  : 'Add Transfer',
                          style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.black), // Text Hitam
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200], // Background tombol close abu muda
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.close, size: 20, color: Colors.black), // Icon Hitam
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    

                    // Type Selector Segmented Button 
                    SegmentedButton<m.TransactionType>(
                      segments: const [
                        ButtonSegment(value: m.TransactionType.income, label: Text('Income')),
                        ButtonSegment(value: m.TransactionType.expense, label: Text('Expense')),
                        ButtonSegment(value: m.TransactionType.transfer, label: Text('Transfer')),
                      ],
                      selected: {_type},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _type = newSelection.first;
                          _categoryId = null;
                          _targetAccountId = null;
                          _amountCtrl.clear();
                          _accountId = null;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Amount Field
                    Text('Amount *', style: theme.textTheme.labelLarge?.copyWith(color: Colors.black)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountCtrl,
                      style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black), // Input Text Hitam
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: Colors.grey[400]), // Hint Abu-abu
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                                Text(
                                  '${currencyProvider.selectedCurrency.code.toUpperCase()} (${currencyProvider.selectedCurrency.symbol})',
                                  style: const TextStyle(color: Colors.black, fontSize: 14), // Currency Hitam
                                  overflow: TextOverflow.ellipsis,
                                ),
                             ],
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty || double.tryParse(v) == null || double.parse(v) <= 0
                          ? 'Enter a valid amount'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    if (_type != m.TransactionType.transfer) ...[
                      Text('Category *', style: theme.textTheme.labelLarge?.copyWith(color: Colors.black)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _categoryId,
                        hint: Text(
                          _type == m.TransactionType.expense
                              ? 'Select expense category'
                              : 'Select income category',
                          style: TextStyle(color: Colors.grey[600]), // Hint Abu gelap
                        ),
                        items: categoryOptions
                            .map((c) => DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text(c.name, style: const TextStyle(color: Colors.black)), // Item Hitam
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _categoryId = value);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        dropdownColor: Colors.white, // Dropdown bg Putih
                        style: const TextStyle(color: Colors.black),
                        validator: (v) => v == null ? 'Select a category' : null,
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      Text('Category *', style: theme.textTheme.labelLarge?.copyWith(color: Colors.black)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.swap_horiz, color: const Color(0xFFC5F244)),
                            const SizedBox(width: 12),
                            Text('Between Accounts',
                                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // From Account Dropdown
                    Text(
                      _type == m.TransactionType.transfer ? 'From Account *' : 'Account *',
                      style: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _accountId,
                      hint: Text('Select account',
                          style: TextStyle(color: Colors.grey[600])),
                      items: repo.accounts
                          .map((a) => DropdownMenuItem<int>(
                                value: a.id,
                                child: Text('${a.name} - ${currencyProvider.formatAmount(a.balance)}', 
                                    style: const TextStyle(color: Colors.black)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _accountId = value;
                          if (_type == m.TransactionType.transfer &&
                              _targetAccountId == value) {
                            _targetAccountId = null;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black),
                      validator: (v) => v == null ? 'Select an account' : null,
                    ),
                    const SizedBox(height: 16),

                    // To Account Dropdown (Transfer only)
                    if (_type == m.TransactionType.transfer) ...[
                      Text('To Account *',
                          style: theme.textTheme.labelLarge?.copyWith(color: Colors.black)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _targetAccountId,
                        hint: Text('Select destination account',
                            style: TextStyle(color: Colors.grey[600])),
                        items: repo.accounts
                            .where((a) => a.id != _accountId)
                            .map((a) => DropdownMenuItem<int>(
                                  value: a.id,
                                  child: Text('${a.name} - ${currencyProvider.formatAmount(a.balance)}',
                                    style: const TextStyle(color: Colors.black)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _targetAccountId = value);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black),
                        validator: (v) => v == null ? 'Select destination account' : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Notes Field
                    Text('Note (Optional)',
                        style: theme.textTheme.labelLarge?.copyWith(color: Colors.black)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.black), // Text Hitam
                      decoration: InputDecoration(
                        hintText: 'Add a note...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[400]!), // Border Abu
                            ),
                            child: const Text('Cancel', style: TextStyle(color: Colors.black)), // Text Hitam
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveTransaction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B3D2E), // Hijau gelap
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Add Transaction',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}