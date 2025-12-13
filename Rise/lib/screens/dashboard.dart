import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../repository.dart';
import '../models.dart' as m;
import '../currency_provider.dart';
import 'add_transaction.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  // Palette Warna
  final Color darkGreen = const Color(0xFF0B3D2E);
  final Color limeAccent = const Color(0xFFC5F244);
  final Color whiteBg = const Color(0xFFFFFFFF);
  final Color cardBg = const Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<Repository>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    // Hitung Balance, Income, Expense
    final income = repo.transactions
        .where((t) => t.type == m.TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final expenses = repo.transactions
        .where((t) => t.type == m.TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final balance = income - expenses;

    // Transaksi Hari Ini
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final todayTransactions = repo.transactions
        .where((t) =>
            t.date != null &&
            t.date!.isAfter(todayStart) &&
            t.date!.isBefore(todayEnd))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF043927),
      body: Stack(
        children: [
          // LAYER 1: FIXED HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              color: const Color(0xFF043927),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Good Morning, Saver!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyProvider.formatAmount(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // LAYER 2: SCROLLABLE CONTENT
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 180),
                Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 100,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: whiteBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Row Income & Expense
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                label: 'Income',
                                amount: income,
                                icon: Icons.arrow_downward,
                                iconColor: const Color(0xFF2ECC71),
                                bgColor: cardBg,
                                currencyProvider: currencyProvider, // FIX: Tambahkan parameter
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                label: 'Expense',
                                amount: expenses,
                                icon: Icons.arrow_upward,
                                iconColor: const Color(0xFFFF6B6B),
                                bgColor: cardBg,
                                currencyProvider: currencyProvider, // FIX: Tambahkan parameter
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Quick Actions
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _quickActionButton(
                              context,
                              label: 'Income',
                              icon: Icons.add,
                              bgColor: cardBg,
                              iconColor: darkGreen,
                              onTap: () => _addTransaction(
                                  context, m.TransactionType.income),
                            ),
                            _quickActionButton(
                              context,
                              label: 'Expense',
                              icon: Icons.remove,
                              bgColor: cardBg,
                              iconColor: Colors.redAccent,
                              onTap: () => _addTransaction(
                                  context, m.TransactionType.expense),
                            ),
                            _quickActionButton(
                              context,
                              label: 'Transfer',
                              icon: Icons.swap_horiz,
                              bgColor: limeAccent,
                              iconColor: Colors.black87,
                              onTap: () => _addTransaction(
                                  context, m.TransactionType.transfer),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Recent Transactions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Transactions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (todayTransactions.isNotEmpty)
                              Text(
                                '${todayTransactions.length} today',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        if (todayTransactions.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long,
                                      size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text('No transactions yet',
                                      style:
                                          TextStyle(color: Colors.grey[400])),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: todayTransactions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (ctx, idx) {
                              final tx = todayTransactions[idx];
                              return _buildTransactionTile(
                                tx,
                                repo,
                                cardBg,
                                currencyProvider, // FIX: Tambahkan parameter
                              );
                            },
                          ),

                        const SizedBox(height: 100),
                      ],
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

  Widget _buildStatCard({
    required String label,
    required double amount,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required CurrencyProvider currencyProvider, // FIX: Tambahkan parameter
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currencyProvider.formatAmount(amount),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.26,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    m.MoneyTransaction tx,
    Repository repo,
    Color tileBgColor,
    CurrencyProvider currencyProvider, // FIX: Tambahkan parameter
  ) {
    final isIncome = tx.type == m.TransactionType.income;
    final isTransfer = tx.type == m.TransactionType.transfer;

    String categoryName = '';
    if (isTransfer) {
      final destAccount = repo.accounts.firstWhere(
        (a) => a.id == tx.targetAccountId,
        orElse: () => m.Account(name: 'Unknown', balance: 0),
      );
      categoryName = 'To: ${destAccount.name}';
    } else {
      categoryName = repo.categories
          .firstWhere((c) => c.id == tx.categoryId,
              orElse: () => m.Category(name: 'Other', icon: null))
          .name;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tileBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward
                  : (isTransfer ? Icons.swap_horiz : Icons.arrow_upward),
              color: isIncome ? const Color(0xFF0B3D2E) : Colors.black54,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('d MMM, HH:mm').format(tx.date ?? DateTime.now()),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome || isTransfer ? '+' : '-'}${currencyProvider.formatAmount(tx.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isIncome ? const Color(0xFF0B3D2E) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _addTransaction(BuildContext context, m.TransactionType type) {
    showDialog(
      context: context,
      builder: (_) => AddTransactionScreen(initialType: type),
    );
  }
}