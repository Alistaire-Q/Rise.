import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../repository.dart';
import '../models.dart' as m;

class CalendarDashboard extends StatefulWidget {
  const CalendarDashboard({Key? key}) : super(key: key);

  @override
  State<CalendarDashboard> createState() => _CalendarDashboardState();
}

class _CalendarDashboardState extends State<CalendarDashboard> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return List.generate(lastDay.day, (i) => DateTime(month.year, month.month, i + 1));
  }

  Map<DateTime, Map<String, double>> _groupTransactionsByDay(List<m.MoneyTransaction> txs) {
    final grouped = <DateTime, Map<String, double>>{};
    for (final tx in txs) {
      final day = DateTime(tx.date!.year, tx.date!.month, tx.date!.day);
      grouped.putIfAbsent(day, () => {'income': 0.0, 'expense': 0.0});
      if (tx.type == m.TransactionType.income) {
        grouped[day]!['income'] = grouped[day]!['income']! + tx.amount;
      } else if (tx.type == m.TransactionType.expense) {
        grouped[day]!['expense'] = grouped[day]!['expense']! + tx.amount;
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<Repository>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final dailyTotals = _groupTransactionsByDay(repo.transactions);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMM().format(_currentMonth)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1));
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1));
          },
        ),
      ),
      body: Column(
        children: [
          // Calendar Grid
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Weekday headers
                Row(
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((day) => Expanded(
                            child: Center(
                              child: Text(day,
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF999999), fontWeight: FontWeight.w600)),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                // Calendar cells
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
                  itemCount: daysInMonth.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (ctx, idx) {
                    final day = daysInMonth[idx];
                    final dayKey = DateTime(day.year, day.month, day.day);
                    final totals = dailyTotals[dayKey] ?? {'income': 0.0, 'expense': 0.0};
                    final hasIncome = totals['income']! > 0;
                    final hasExpense = totals['expense']! > 0;

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${day.day}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                          const SizedBox(height: 2),
                          if (hasExpense)
                            Text(currencyProvider.formatAmount(totals['expense']!),
                                style: const TextStyle(fontSize: 8, color: Color(0xFFE53935))),
                          if (hasIncome)
                            Text(currencyProvider.formatAmount(totals['income']!),
                                style: const TextStyle(fontSize: 8, color: Color(0xFF1E88E5))),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Transaction List
          Expanded(
            child: ListView.builder(
              itemCount: repo.transactions.length,
              itemBuilder: (ctx, idx) {
                final tx = repo.transactions[idx];
                final isIncome = tx.type == m.TransactionType.income;
                final categoryName = repo.categories.firstWhere((c) => c.id == tx.categoryId, orElse: () => m.Category(name: 'Uncategorized')).name;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: const Color(0xFFEEEEEE), width: 0.5))),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isIncome ? const Color(0xFFE3F2FD) : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                              size: 18, color: isIncome ? const Color(0xFF1E88E5) : const Color(0xFFE53935)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(categoryName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
                            Text(DateFormat.yMMMd().format(tx.date ?? DateTime.now()),
                                style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                          ],
                        ),
                      ),
                      Text(currencyProvider.formatAmount(tx.amount),
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isIncome ? const Color(0xFF1E88E5) : const Color(0xFFE53935))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
