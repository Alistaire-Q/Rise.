import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../repository.dart';
import '../models.dart' as m;
import '../currency_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isExpense = true;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // Warna Tema
  final Color _darkGreen = const Color(0xFF052e23);
  final Color _limeAccent = const Color(0xFFC5F244);

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<Repository>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context); // Tambahan baru
    
    // --- LOGIC START (Tidak diubah) ---
    // Get transactions for current month
    final monthTransactions = repo.transactions.where((t) {
      final txDate = t.date ?? DateTime.now();
      return txDate.year == _currentMonth.year &&
          txDate.month == _currentMonth.month &&
          (_isExpense
              ? t.type == m.TransactionType.expense
              : t.type == m.TransactionType.income);
    }).toList();

    // Group by category
    final categoryTotals = <int, double>{};
    for (final tx in monthTransactions) {
      if (tx.categoryId != null) {
        categoryTotals[tx.categoryId!] =
            (categoryTotals[tx.categoryId] ?? 0.0) + tx.amount;
      }
    }

    // Create category stats
    final categoryStats = <m.CategoryStat>[];
    for (final entry in categoryTotals.entries) {
              final category = repo.categories.firstWhere(
          (c) => c.id == entry.key,
          orElse: () => m.Category(name: 'Other', icon: null),
        );
      categoryStats.add(
        m.CategoryStat(
          name: category.name,
          amount: entry.value,
          color: _getCategoryColor(category.name, _isExpense),
          icon: _getCategoryIcon(category.name),
        ),
      );
    }

    // Sort by amount (highest first)
    categoryStats.sort((a, b) => b.amount.compareTo(a.amount));

    final total = categoryStats.fold<double>(0, (sum, stat) => sum + stat.amount);
    // --- LOGIC END ---

    return Scaffold(
      backgroundColor: _darkGreen, // Background atas hijau gelap
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER ROW (Title Kiri, Navigasi Bulan Kanan)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Memisahkan kiri dan kanan
                children: [
                  // Title
                  Text(
                    _isExpense ? 'Expenses' : 'Income',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Navigasi Bulan (Kecil di Pojok Kanan)
                  Container(
                    height: 36, // Tinggi diperkecil agar compact
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: _limeAccent,
                      borderRadius: BorderRadius.circular(30), // Radius 30
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Hanya selebar konten
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero, // Hapus padding default icon
                          constraints: const BoxConstraints(), // Hapus constraint minimum
                          iconSize: 18, // Icon kecil
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month - 1,
                              );
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            // Format diperpendek (MMM yyyy) agar muat ukuran kecil
                            DateFormat('MMM yyyy').format(_currentMonth),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13, // Font size kecil
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 18,
                          icon: const Icon(Icons.arrow_forward, color: Colors.black87),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month + 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. WHITE CONTAINER (Bagian Utama)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TOGGLE SWITCH (Expenses / Income)
                      Container(
                        height: 50,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isExpense = true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _isExpense ? const Color(0xFFCDFE52) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Expenses',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _isExpense ? Colors.black : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isExpense = false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !_isExpense ? const Color(0xFFCDFE52) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Income',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: !_isExpense ? Colors.black : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      // DONUT CHART
                      if (categoryStats.isNotEmpty)
                        Center(
                          child: SizedBox(
                            height: 220,
                            width: 220,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(220, 220),
                                  painter: DonutChartPainterWithLabels(
                                    categoryStats: categoryStats,
                                    total: total,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Total ${_isExpense ? 'Expenses' : 'Income'}',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_isExpense ? '-' : ''}${currencyProvider.formatAmount(total)}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'No data available',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),

                      // LIST HEADER
                      if (categoryStats.isNotEmpty) ...[
                        const Text(
                          'Top Spending Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // CATEGORY LIST ITEMS
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoryStats.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 24),
                          itemBuilder: (ctx, idx) {
                            final stat = categoryStats[idx];
                            final percentage = total > 0 ? (stat.amount / total * 100) : 0.0;

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    // Icon
                                    Icon(
                                      stat.icon, 
                                      color: stat.color,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    // Name & Percentage
                                    Text(
                                      '${stat.name} (${percentage.toStringAsFixed(0)}%)',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Amount
                                    Text(
                                      '${_isExpense ? '-' : ''}${currencyProvider.formatAmount(stat.amount)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Progress Bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(stat.color),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 40), // Bottom padding
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  Color _getCategoryColor(String categoryName, bool isExpense) {
    final expenseColors = {
      'Food': const Color(0xFFE57373), 
      'Transportation': const Color(0xFFFFB74D), 
      'Healthcare': const Color(0xFFFFF176), 
      'Shopping': const Color(0xFF64B5F6), 
      'Other Expense': const Color(0xFFBA68C8), 
    };

    final incomeColors = {
      'Salary': const Color(0xFF4DB6AC),
      'Freelance': const Color(0xFF81C784),
      'Gift': const Color(0xFF4DD0E1),
      'Investment': const Color(0xFFAED581),
      'Other Income': const Color(0xFF90A4AE),
    };

    final colorMap = isExpense ? expenseColors : incomeColors;
    return colorMap[categoryName] ?? Colors.grey;
  }

  IconData _getCategoryIcon(String categoryName) {
    final iconMap = {
      'Food': Icons.restaurant_menu,
      'Food & Dining': Icons.restaurant_menu,
      'Transportation': Icons.directions_car_filled,
      'Healthcare': Icons.medical_services,
      'Shopping': Icons.shopping_bag,
      'Other Expense': Icons.receipt,
      'Salary': Icons.work,
      'Freelance': Icons.computer,
      'Gift': Icons.card_giftcard,
      'Investment': Icons.show_chart,
      'Other Income': Icons.attach_money,
    };
    return iconMap[categoryName] ?? Icons.category;
  }
}

// Custom Painter
class DonutChartPainterWithLabels extends CustomPainter {
  final List<m.CategoryStat> categoryStats;
  final double total;

  DonutChartPainterWithLabels({
    required this.categoryStats,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 50.0; 
    final radius = (size.width - strokeWidth) / 2;

    double startAngle = -pi / 2;

    for (final stat in categoryStats) {
      final sweepAngle = (stat.amount / total) * 2 * pi;

      final paint = Paint()
        ..color = stat.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(DonutChartPainterWithLabels oldDelegate) => true;
}