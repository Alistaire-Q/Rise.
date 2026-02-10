import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository.dart';
import '../models.dart' as m;
import '../currency_provider.dart';

class StatisticsAnalysis extends StatelessWidget {
  const StatisticsAnalysis({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<Repository>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final expenses = repo.transactions.where((t) => t.type == m.TransactionType.expense).toList();

    // Group expenses by category (skip null categoryIds)
    final categoryTotals = <int, double>{};
    for (final expense in expenses) {
      if (expense.categoryId != null) {
        categoryTotals[expense.categoryId!] = (categoryTotals[expense.categoryId] ?? 0.0) + expense.amount;
      }
    }

    final sortedCategories = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = categoryTotals.values.fold<double>(0, (sum, val) => sum + val);

    const colors = [
      Color(0xFFE53935),
      Color(0xFF1E88E5),
      Color(0xFFFB8C00),
      Color(0xFF43A047),
      Color(0xFF8E24AA),
      Color(0xFF00ACC1),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Analysis'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Donut Chart Alternative (Simple visual)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Simple circular progress visualization
                    SizedBox(
                      height: 160,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF5F5F5),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(currencyProvider.formatAmount(total),
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                                const Text('Total Spending', style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category color legend
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        sortedCategories.length.clamp(0, 6),
                        (idx) {
                          final entry = sortedCategories[idx];
                          final categoryName = repo.categories
                              .firstWhere((c) => c.id == entry.key, orElse: () => m.Category(name: 'Uncategorized'))
                              .name;
                          final color = colors[idx % colors.length];

                          return Chip(
                            label: Text(categoryName, style: const TextStyle(fontSize: 11)),
                            backgroundColor: color.withOpacity(0.2),
                            side: BorderSide(color: color),
                            labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Category Breakdown List
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: List.generate(
                    sortedCategories.length,
                    (idx) {
                      final entry = sortedCategories[idx];
                      final categoryId = entry.key;
                      final amount = entry.value;
                      final percentage = total > 0 ? (amount / total * 100) : 0;
                      final categoryName = repo.categories
                          .firstWhere((c) => c.id == categoryId, orElse: () => m.Category(name: 'Uncategorized'))
                          .name;
                      final color = colors[idx % colors.length];

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(categoryName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
                                      LinearProgressIndicator(
                                        value: percentage / 100,
                                        minHeight: 4,
                                        backgroundColor: const Color(0xFFEEEEEE),
                                        valueColor: AlwaysStoppedAnimation<Color>(color),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(currencyProvider.formatAmount(amount),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                                    Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (idx < sortedCategories.length - 1) const Divider(height: 1),
                        ],
                      );
                    },
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
