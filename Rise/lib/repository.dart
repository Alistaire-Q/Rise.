import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'models.dart' as m;

class Repository extends ChangeNotifier {
  // Kita tidak butuh DatabaseHelper lagi
  // Repository(this.db); dihapus

  // --- AKSES BOX DATABASE ---
  // Pastikan nama box sama persis dengan yang dibuka di main.dart
  final Box<m.MoneyTransaction> _transactionBox = Hive.box<m.MoneyTransaction>('transactions_box');
  final Box<m.Account> _accountBox = Hive.box<m.Account>('accounts_box');
  final Box<m.Category> _categoryBox = Hive.box<m.Category>('categories_box');

  // --- GETTERS (Mengubah Data Hive menjadi List untuk UI) ---
  List<m.Account> get accounts => _accountBox.values.toList();
  List<m.Category> get categories => _categoryBox.values.toList();
  
  List<m.MoneyTransaction> get transactions {
    // Ambil transaksi, urutkan dari yang terbaru
    final list = _transactionBox.values.toList();
    list.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
    return list;
  }

  // --- INITIALIZATION ---
  Future<void> init() async {
    debugPrint('Repository initialized with ${_accountBox.length} accounts');

    // Cek jika akun kosong, isi dengan data default
    if (_accountBox.isEmpty) {
      await _initializePredefinedAccounts();
    }

    // Cek jika kategori kosong, isi dengan data default
    if (_categoryBox.isEmpty) {
      await _initializePredefinedCategories();
    }

    notifyListeners();
  }

  Future<void> _initializePredefinedAccounts() async {
    for (final accountName in m.PredefinedData.accountNames) {
      await addAccount(m.Account(name: accountName, balance: 0.0));
    }
  }

  Future<void> _initializePredefinedCategories() async {
    for (final catName in m.PredefinedData.expenseCategories) {
      await addCategory(m.Category(name: catName, icon: null)); // Icon sementara null/string
    }
    for (final catName in m.PredefinedData.incomeCategories) {
      await addCategory(m.Category(name: catName, icon: null));
    }
  }

  // --- CRUD OPERATIONS ---

  Future<void> addAccount(m.Account a) async {
    // 1. Simpan ke Hive, Hive akan mengembalikan ID unik (key)
    final int key = await _accountBox.add(a);
    
    // 2. Update object tersebut agar field 'id' terisi dengan key dari Hive
    final newAccount = a.copyWith(id: key);
    await _accountBox.put(key, newAccount);
    
    debugPrint('Added account: ${newAccount.name} with ID: $key');
    notifyListeners();
  }

  Future<void> addCategory(m.Category c) async {
    final int key = await _categoryBox.add(c);
    final newCategory = c.copyWith(id: key);
    await _categoryBox.put(key, newCategory);
    notifyListeners();
  }

  Future<void> addTransaction(m.MoneyTransaction t) async {
    final int key = await _transactionBox.add(t);
    // Jika perlu simpan ID transaksi:
    final newTransaction = t.copyWith(id: key);
    await _transactionBox.put(key, newTransaction);
    
    notifyListeners();
  }

  /// Update account balance atomically
  Future<void> updateAccountBalance(int accountId, double newBalance) async {
    // Cari akun berdasarkan ID
    final account = getAccountById(accountId);
    if (account != null) {
      // Buat copy akun dengan saldo baru
      final updatedAccount = account.copyWith(balance: newBalance);
      // Simpan kembali ke Hive (menimpa data lama berdasarkan key/id)
      await _accountBox.put(accountId, updatedAccount);
      
      debugPrint('Balance updated for account $accountId to: \$$newBalance');
      notifyListeners();
    }
  }

  /// Execute atomic transfer (debit source, credit destination)
  Future<bool> executeAtomicTransfer({
    required int sourceAccountId,
    required int destinationAccountId,
    required double amount,
  }) async {
    try {
      final sourceAccount = getAccountById(sourceAccountId);
      final destAccount = getAccountById(destinationAccountId);

      if (sourceAccount == null || destAccount == null) return false;

      // Validate sufficient balance
      if (sourceAccount.balance < amount) return false;

      // Update balances
      final newSourceBalance = sourceAccount.balance - amount;
      final newDestBalance = destAccount.balance + amount;

      await updateAccountBalance(sourceAccountId, newSourceBalance);
      await updateAccountBalance(destinationAccountId, newDestBalance);

      // notifyListeners sudah dipanggil di updateAccountBalance
      return true;
    } catch (e) {
      debugPrint('Transfer error: $e');
      return false;
    }
  }

  /// Get account by ID
  m.Account? getAccountById(int accountId) {
    // Di Hive, jika kita menggunakan key sebagai ID, kita bisa langsung get(key)
    return _accountBox.get(accountId);
  }
  
  // Opsional: Hapus Transaksi
  Future<void> deleteTransaction(int indexOrKey) async {
     // Hati-hati: index di list UI mungkin beda dengan key di Hive
     // Jika di UI kamu pakai key:
     await _transactionBox.delete(indexOrKey);
     notifyListeners();
  }
}