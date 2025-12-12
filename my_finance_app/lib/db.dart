import 'package:flutter/foundation.dart';
import 'dart:async';
// use a prefixed import for the models used by Repository:
import 'models.dart' as m;

/// Minimal DatabaseHelper stub to avoid platform plugin calls (e.g. path_provider)
/// This implementation intentionally avoids native-only plugins so the app can run on web.
/// Replace this with a real storage implementation (sqflite for mobile, IndexedDB for web)
/// when you want persistence across runs.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // In-memory counters to generate temporary ids (only for session)
  int _nextAccountId = 1;
  int _nextCategoryId = 1;
  int _nextTransactionId = 1;

  // In-memory lists (session-only)
  final List<m.Account> _accounts = <m.Account>[];
  final List<m.Category> _categories = <m.Category>[];
  final List<m.MoneyTransaction> _transactions = <m.MoneyTransaction>[];

  /// Returns accounts with their current balances
  Future<List<m.Account>> getAccounts() async {
    // Return a copy to avoid external mutation
    return List<m.Account>.from(_accounts);
  }

  /// Returns categories (empty by default).
  Future<List<m.Category>> getCategories() async {
    return List<m.Category>.from(_categories);
  }

  /// Returns transactions (empty by default).
  Future<List<m.MoneyTransaction>> getTransactions({int limit = 200}) async {
    // return most recent first if stored with date
    final txs = List<m.MoneyTransaction>.from(_transactions);
    txs.sort((a, b) {
      final da = a.date;
      final db = b.date;
      if (da == null || db == null) return 0;
      return db.compareTo(da);
    });
    if (limit > 0 && txs.length > limit) {
      return txs.sublist(0, limit);
    }
    return txs;
  }

  /// Insert account into in-memory list with proper balance storage
  Future<void> insertAccount(m.Account a) async {
    try {
      final id = (a.id == null || a.id == 0) ? (_nextAccountId++) : a.id!;
      final acc = m.Account(
        id: id,
        name: a.name,
        balance: a.balance, // Properly store the balance
        isActive: a.isActive,
        createdAt: a.createdAt ?? DateTime.now(),
      );
      _accounts.add(acc);
      debugPrint('Account created: ${acc.name} with balance: \$${acc.balance}');
    } catch (e) {
      debugPrint('Error inserting account: $e');
    }
  }

  /// Insert transaction into in-memory list
  Future<void> insertTransaction(m.MoneyTransaction t) async {
    try {
      final id = (t.id == null || t.id == 0) ? (_nextTransactionId++) : t.id!;
      final tx = m.MoneyTransaction(
        id: id,
        amount: t.amount,
        type: t.type,
        accountId: t.accountId,
        categoryId: t.categoryId,
        targetAccountId: t.targetAccountId,
        date: t.date ?? DateTime.now(),
        notes: t.notes,
        transferId: t.transferId,
        status: t.status,
      );
      _transactions.add(tx);
      debugPrint('Transaction created: ${tx.type} - \$${tx.amount}');
    } catch (e) {
      debugPrint('Error inserting transaction: $e');
    }
  }

  /// Update account balance
  Future<void> updateAccountBalance(int accountId, double newBalance) async {
    try {
      final index = _accounts.indexWhere((a) => a.id == accountId);
      if (index != -1) {
        _accounts[index] = _accounts[index].copyWith(balance: newBalance);
        debugPrint('Account $accountId balance updated to: \$$newBalance');
      }
    } catch (e) {
      debugPrint('Error updating balance: $e');
    }
  }

  // Optional helper: clear all in-memory data (useful for testing)
  Future<void> clearAll() async {
    _accounts.clear();
    _categories.clear();
    _transactions.clear();
    _nextAccountId = 1;
    _nextCategoryId = 1;
    _nextTransactionId = 1;
  }
}
