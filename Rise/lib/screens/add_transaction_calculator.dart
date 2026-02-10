import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository.dart';
import '../models.dart' as m;

class AddTransactionCalculator extends StatefulWidget {
  const AddTransactionCalculator({Key? key}) : super(key: key);

  @override
  State<AddTransactionCalculator> createState() => _AddTransactionCalculatorState();
}

class _AddTransactionCalculatorState extends State<AddTransactionCalculator> {
  String _display = '0';
  double _amount = 0.0;
  m.TransactionType _type = m.TransactionType.expense;
  int? _selectedCategoryId;
  final DateTime _selectedDate = DateTime.now();

  void _onKeyPress(String key) {
    setState(() {
      if (key == 'C') {
        _display = '0';
        _amount = 0.0;
      } else if (key == '⌫') {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
        _amount = double.tryParse(_display) ?? 0.0;
      } else if (key == '.') {
        if (!_display.contains('.')) {
          _display += key;
        }
      } else if (key == '✓') {
        _amount = double.tryParse(_display) ?? 0.0;
        _saveTransaction();
      } else {
        if (_display == '0') {
          _display = key;
        } else {
          _display += key;
        }
        _amount = double.tryParse(_display) ?? 0.0;
      }
    });
  }

  void _saveTransaction() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a category')));
      return;
    }
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid amount')));
      return;
    }

    final repo = Provider.of<Repository>(context, listen: false);
    if (repo.accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add an account first')));
      return;
    }

    final tx = m.MoneyTransaction(
      amount: _amount,
      type: _type,
      accountId: repo.accounts.first.id!,
      categoryId: _selectedCategoryId!,
      date: _selectedDate,
      notes: '',
    );

    await repo.addTransaction(tx);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<Repository>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
      ),
      body: Column(
        children: [
          // Top section: Amount display & type selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Amount', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_display, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                ),
                const SizedBox(height: 12),
                SegmentedButton<m.TransactionType>(
                  segments: const [
                    ButtonSegment(value: m.TransactionType.expense, label: Text('Expense')),
                    ButtonSegment(value: m.TransactionType.income, label: Text('Income')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (newSelection) {
                    setState(() => _type = newSelection.first);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Category Grid
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Category', style: TextStyle(fontSize: 12, color: Color(0xFF999999), fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1, mainAxisSpacing: 8, crossAxisSpacing: 8),
                  itemCount: repo.categories.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (ctx, idx) {
                    final cat = repo.categories[idx];
                    final isSelected = _selectedCategoryId == cat.id;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFEEEEEE)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.category, size: 24, color: isSelected ? Colors.white : const Color(0xFF999999)),
                            const SizedBox(height: 4),
                            Text(cat.name, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : const Color(0xFF333333)), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Numeric Keypad
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.2, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemCount: 12,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (ctx, idx) {
                  final keys = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '.', '0', 'C'];
                  final key = keys[idx];
                  final isFunction = ['C'].contains(key);

                  return GestureDetector(
                    onTap: () => _onKeyPress(key),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isFunction ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(key, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isFunction ? const Color(0xFFE53935) : const Color(0xFF333333))),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Action Buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onKeyPress('⌫'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFEEEEEE)), borderRadius: BorderRadius.circular(8)),
                      child: const Center(child: Icon(Icons.backspace, color: Color(0xFF999999))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onKeyPress('✓'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFF1E88E5), borderRadius: BorderRadius.circular(8)),
                      child: const Center(child: Icon(Icons.check, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
