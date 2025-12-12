import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Wajib ada untuk generate file penghubung
part 'models.g.dart';

/// Enums
@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
  @HiveField(2)
  transfer
}

@HiveType(typeId: 2)
enum TransactionStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed,
  @HiveField(2)
  failed,
  @HiveField(3)
  cancelled
}

/// Models

// Class Currency tidak perlu disimpan ke DB (static data)
class Currency {
  final String code;
  final String name;
  final String symbol;
  final double exchangeRate;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.exchangeRate,
  });

  static const Currency usd = Currency(
    code: 'USD',
    name: 'United States Dollar',
    symbol: r'$',
    exchangeRate: 1.0,
  );

  static const Currency idr = Currency(
    code: 'IDR',
    name: 'Indonesian Rupiah',
    symbol: 'Rp ',
    exchangeRate: 16000.0,
  );

  static const List<Currency> values = [usd, idr];

  factory Currency.fromString(String value) {
    return values.firstWhere(
      (c) => c.code.toLowerCase() == value.toLowerCase(),
      orElse: () => usd,
    );
  }
}

@HiveType(typeId: 3)
class Account extends HiveObject {
  @HiveField(0)
  final int? id; // Hive sebenarnya punya key sendiri, tapi kita keep id ini
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final double balance;
  
  @HiveField(3)
  final bool isActive;
  
  @HiveField(4)
  final DateTime? createdAt;

  Account({
    this.id,
    required this.name,
    required this.balance,
    this.isActive = true,
    this.createdAt,
  });

  Account copyWith({
    int? id,
    String? name,
    double? balance,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@HiveType(typeId: 4)
class Category extends HiveObject {
  @HiveField(0)
  final int? id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? icon;

  Category({
    this.id,
    required this.name,
    this.icon,
  });

  Category copyWith({
    int? id,
    String? name,
    String? icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }
}

@HiveType(typeId: 0)
class MoneyTransaction extends HiveObject {
  @HiveField(0)
  final int? id; // Opsional jika pakai Hive key
  
  @HiveField(1)
  final double amount;
  
  @HiveField(2)
  final TransactionType type;
  
  @HiveField(3)
  final int accountId;
  
  @HiveField(4)
  final int? categoryId;
  
  @HiveField(5)
  final int? targetAccountId;
  
  @HiveField(6)
  final DateTime? date;
  
  @HiveField(7)
  final String? notes;
  
  @HiveField(8)
  final String? transferId;
  
  @HiveField(9)
  final TransactionStatus status;

  MoneyTransaction({
    this.id,
    required this.amount,
    required this.type,
    required this.accountId,
    this.categoryId,
    this.targetAccountId,
    this.date,
    this.notes,
    this.transferId,
    this.status = TransactionStatus.pending,
  });

  MoneyTransaction copyWith({
    int? id,
    double? amount,
    TransactionType? type,
    int? accountId,
    int? categoryId,
    int? targetAccountId,
    DateTime? date,
    String? notes,
    String? transferId,
    TransactionStatus? status,
  }) {
    return MoneyTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      targetAccountId: targetAccountId ?? this.targetAccountId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      transferId: transferId ?? this.transferId,
      status: status ?? this.status,
    );
  }
}

// --- CLASS LOGIKA/HELPER DI BAWAH INI TIDAK PERLU DISIMPAN DI DB ---

class TransferResult {
  final bool success;
  final String message;
  final String? transferId;
  final MoneyTransaction? sourceTransaction;
  final MoneyTransaction? destinationTransaction;

  TransferResult({
    required this.success,
    required this.message,
    this.transferId,
    this.sourceTransaction,
    this.destinationTransaction,
  });
}

class AuditLog {
  final int? id;
  final String action;
  final String description;
  final int? accountId;
  final int? transactionId;
  final String? userId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  AuditLog({
    this.id,
    required this.action,
    required this.description,
    this.accountId,
    this.transactionId,
    this.userId,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  })  : timestamp = timestamp ?? DateTime.now(),
        metadata = metadata ?? {};
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

class TransactionValidator {
  static const double maxTransferLimit = 100000.0;
  static const double minTransferAmount = 0.01;

  static ValidationResult validateTransfer({
    required double amount,
    required Account sourceAccount,
    required Account destinationAccount,
    String Function(double)? currencyFormatter,
  }) {
    if (amount <= 0) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Amount must be greater than zero',
      );
    }

    if (amount < minTransferAmount) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Amount must be at least $minTransferAmount',
      );
    }

    if (amount > maxTransferLimit) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Transfer limit is $maxTransferLimit per transaction',
      );
    }

    if (sourceAccount.balance < amount) {
      final formattedBalance = currencyFormatter != null
          ? currencyFormatter(sourceAccount.balance)
          : sourceAccount.balance.toStringAsFixed(2);
      return ValidationResult(
        isValid: false,
        errorMessage: 'Insufficient balance. Available: $formattedBalance',
      );
    }

    if (!sourceAccount.isActive) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Source account is not active',
      );
    }

    if (!destinationAccount.isActive) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Destination account is not active',
      );
    }

    if (sourceAccount.id == destinationAccount.id) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Source and destination accounts must be different',
      );
    }

    return ValidationResult(isValid: true);
  }
}

class CategoryStat {
  final String name;
  final double amount;
  final Color color;
  final IconData icon;

  CategoryStat({
    required this.name,
    required this.amount,
    required this.color,
    required this.icon,
  });
}

class PredefinedData {
  static final List<String> accountNames = ['Cash', 'Digital Wallet', 'Bank'];

  static final List<String> expenseCategories = [
    'Food',
    'Transportation',
    'Healthcare',
    'Shopping',
    'Other Expense',
  ];

  static final List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Gift',
    'Investment',
    'Other Income',
  ];
}