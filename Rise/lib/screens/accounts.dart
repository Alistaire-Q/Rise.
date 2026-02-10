import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../repository.dart';
import '../models.dart' as m;
import '../currency_provider.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  int? _expandedAccountId;

  // Warna Tema
  final Color _darkGreen = const Color(0xFF052e23);
  final Color _limeAccent = const Color(0xFFC5F244);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  void _addAccount() async {
    if (_nameCtrl.text.isEmpty || _balanceCtrl.text.isEmpty) return;

    final repo = Provider.of<Repository>(context, listen: false);
    final account = m.Account(
      name: _nameCtrl.text,
      balance: double.tryParse(_balanceCtrl.text) ?? 0.0,
    );

    await repo.addAccount(account);
    _nameCtrl.clear();
    _balanceCtrl.clear();
    if (mounted) Navigator.pop(context);
  }

  void _showAddAccountDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Account',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _darkGreen,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _balanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Initial Balance',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Logic Methods ---
  List<m.MoneyTransaction> _getAccountTransactions(int accountId) {
    final repo = Provider.of<Repository>(context, listen: false);
    final list = repo.transactions
        .where((t) => t.accountId == accountId || t.targetAccountId == accountId)
        .toList();
    list.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
    return list;
  }

  String _getTransactionLabel(m.MoneyTransaction tx, int accountId) {
    if (tx.type == m.TransactionType.transfer) {
      if (tx.accountId == accountId) {
        return 'Transfer Out';
      } else {
        return 'Transfer In';
      }
    } else if (tx.type == m.TransactionType.income) {
      return 'Income';
    } else {
      return 'Expense';
    }
  }

  IconData _getTransactionIcon(m.MoneyTransaction tx, int accountId) {
    if (tx.type == m.TransactionType.transfer) {
      if (tx.accountId == accountId) {
        return Icons.arrow_upward;
      } else {
        return Icons.arrow_downward;
      }
    } else if (tx.type == m.TransactionType.income) {
      return Icons.trending_up;
    } else {
      return Icons.trending_down;
    }
  }

  Color _getTransactionColor(m.MoneyTransaction tx, int accountId) {
    if (tx.type == m.TransactionType.transfer) {
      if (tx.accountId == accountId) {
        return Colors.orange;
      } else {
        return Colors.blue;
      }
    } else if (tx.type == m.TransactionType.income) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String _getDestinationAccountName(m.MoneyTransaction tx, Repository repo) {
    if (tx.type == m.TransactionType.transfer && tx.targetAccountId != null) {
      final destAccount = repo.accounts.firstWhere(
        (a) => a.id == tx.targetAccountId,
        orElse: () => m.Account(name: 'Unknown', balance: 0),
      );
      return destAccount.name;
    }
    return '';
  }

  Map<String, dynamic> _getAccountIcon(String accountName) {
    switch (accountName.toLowerCase()) {
      case 'cash':
        return {'icon': Icons.wallet, 'color': const Color(0xFF2ECC71)};
      case 'bank':
        return {'icon': Icons.account_balance, 'color': const Color(0xFF00B4D8)};
      case 'digital wallet':
        return {'icon': Icons.smartphone, 'color': const Color(0xFF9C27B0)};
      default:
        return {'icon': Icons.account_balance_wallet, 'color': const Color(0xFF1E88E5)};
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<Repository>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final totalBalance = repo.accounts.fold<double>(0, (sum, acc) => sum + (acc.balance));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. RISE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _limeAccent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rise',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currencyProvider.formatAmount(totalBalance),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Total Networth',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                
                // 2. HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Accounts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    InkWell(
                      onTap: _showAddAccountDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _limeAccent.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 18, color: _darkGreen),
                            const SizedBox(width: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: _darkGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. ACCOUNTS LIST
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: repo.accounts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, idx) {
                    final account = repo.accounts[idx];
                    final isExpanded = _expandedAccountId == account.id;
                    final transactions = _getAccountTransactions(account.id ?? 0);
                    final iconData = _getAccountIcon(account.name);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _expandedAccountId = isExpanded ? null : account.id;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                                    ),
                                    child: Icon(
                                      iconData['icon'],
                                      color: iconData['color'],
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Active',
                                          style: TextStyle(
                                            color: _darkGreen.withOpacity(0.6),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        currencyProvider.formatAmount(account.balance),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Icon(
                                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        size: 20,
                                        color: Colors.grey[400],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedCrossFade(
                            firstChild: Container(height: 0),
                            secondChild: Column(
                              children: [
                                Divider(height: 1, color: Colors.grey[200]),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                                  ),
                                  child: transactions.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Icon(Icons.receipt_long_outlined, size: 32, color: Colors.grey[300]),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'No transactions yet',
                                                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: transactions.length,
                                          separatorBuilder: (_, __) => Divider(
                                            height: 1,
                                            color: Colors.grey[100],
                                            indent: 16,
                                            endIndent: 16,
                                          ),
                                          itemBuilder: (_, tidx) {
                                            final tx = transactions[tidx];
                                            final isIncome = tx.type == m.TransactionType.income ||
                                                (tx.type == m.TransactionType.transfer && tx.targetAccountId == account.id);
                                            final color = _getTransactionColor(tx, account.id ?? 0);
                                            final label = _getTransactionLabel(tx, account.id ?? 0);
                                            final destAccountName = _getDestinationAccountName(tx, repo);

                                            return ListTile(
                                              dense: true,
                                              leading: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  _getTransactionIcon(tx, account.id ?? 0),
                                                  color: color,
                                                  size: 16,
                                                ),
                                              ),
                                              title: Text(
                                                tx.type == m.TransactionType.transfer ? '$label to $destAccountName' : label,
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                              ),
                                              subtitle: Text(
                                                DateFormat('MMM d, HH:mm').format(tx.date ?? DateTime.now()),
                                                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${isIncome ? '+' : '-'}${currencyProvider.formatAmount(tx.amount)}',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: isIncome ? Colors.green[600] : Colors.red[400],
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                                    onPressed: () async {
                                                      final confirm = await showDialog<bool>(
                                                        context: context,
                                                        builder: (_) => AlertDialog(
                                                          title: const Text('Delete transaction?'),
                                                          content: const Text(
                                                              'This will reverse the transaction and update account balances.'),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () => Navigator.pop(context, false),
                                                                child: const Text('Cancel')),
                                                            TextButton(
                                                                onPressed: () => Navigator.pop(context, true),
                                                                child: const Text('Delete')),
                                                          ],
                                                        ),
                                                      );
                                                      if (confirm == true && tx.id != null) {
                                                        await Provider.of<Repository>(context, listen: false)
                                                            .deleteTransaction(tx.id!);
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(content: Text('Transaction deleted')));
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}