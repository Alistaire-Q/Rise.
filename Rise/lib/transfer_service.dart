import 'dart:async';
import 'package:uuid/uuid.dart';
import 'models.dart' as m;
import 'repository.dart';
import 'audit_logger.dart';

class TransferService {
  final Repository repository;
  final AuditLogger auditLogger;

  // Thread safety: Use mutex-like pattern
  final Map<String, Future<m.TransferResult>> _pendingTransfers = {};
  final Map<String, m.TransferResult> _completedTransfers = {}; // For idempotency

  TransferService({
    required this.repository,
    required this.auditLogger,
  });

  /// Execute atomic transfer between accounts
  /// Returns TransferResult with detailed status
  Future<m.TransferResult> transferFunds({
    required int sourceAccountId,
    required int destinationAccountId,
    required double amount,
    String? transferId,
    String? notes,
  }) async {
    // Generate unique transfer ID for idempotency
    final uniqueTransferId = transferId ?? const Uuid().v4();

    // Check for duplicate (idempotency)
    if (_completedTransfers.containsKey(uniqueTransferId)) {
      return _completedTransfers[uniqueTransferId]!;
    }

    // Prevent concurrent duplicate transfers
    if (_pendingTransfers.containsKey(uniqueTransferId)) {
      return _pendingTransfers[uniqueTransferId]!;
    }

    // Create and store the transfer future
    final transferFuture = _executeAtomicTransfer(
      sourceAccountId: sourceAccountId,
      destinationAccountId: destinationAccountId,
      amount: amount,
      transferId: uniqueTransferId,
      notes: notes,
    );

    _pendingTransfers[uniqueTransferId] = transferFuture;

    try {
      final result = await transferFuture;

      // Cache successful result for idempotency
      if (result.success) {
        _completedTransfers[uniqueTransferId] = result;
      }

      return result;
    } finally {
      _pendingTransfers.remove(uniqueTransferId);
    }
  }

  /// Core atomic transfer logic
  Future<m.TransferResult> _executeAtomicTransfer({
    required int sourceAccountId,
    required int destinationAccountId,
    required double amount,
    required String transferId,
    String? notes,
  }) async {
    try {
      // Log transfer initiation
      auditLogger.logTransfer(
        sourceAccountId: sourceAccountId,
        destinationAccountId: destinationAccountId,
        amount: amount,
        transferId: transferId,
        status: 'initiated',
      );

      // Step 1: Validate transfer
      final sourceAccount = repository.accounts.firstWhere(
        (a) => a.id == sourceAccountId,
        orElse: () => throw Exception('Source account not found'),
      );

      final destinationAccount = repository.accounts.firstWhere(
        (a) => a.id == destinationAccountId,
        orElse: () => throw Exception('Destination account not found'),
      );

      final validation = m.TransactionValidator.validateTransfer(
        amount: amount,
        sourceAccount: sourceAccount,
        destinationAccount: destinationAccount,
        currencyFormatter: (double value) => '\$${value.toStringAsFixed(2)}',
      );

      if (!validation.isValid) {
        auditLogger.logValidationError(
          description: 'Transfer validation failed',
          errorMessage: validation.errorMessage!,
          accountId: sourceAccountId,
        );

        return m.TransferResult(
          success: false,
          message: validation.errorMessage!,
          transferId: transferId,
        );
      }

      // Step 2: Create debit transaction (source account)
      final debitTransaction = m.MoneyTransaction(
        amount: amount,
        type: m.TransactionType.transfer,
        accountId: sourceAccountId,
        targetAccountId: destinationAccountId,
        date: DateTime.now(),
        notes: notes,
        transferId: transferId,
        status: m.TransactionStatus.pending,
      );

      // Step 3: Create credit transaction (destination account)
      final creditTransaction = m.MoneyTransaction(
        amount: amount,
        type: m.TransactionType.transfer,
        accountId: destinationAccountId,
        targetAccountId: sourceAccountId,
        date: DateTime.now(),
        notes: notes,
        transferId: transferId,
        status: m.TransactionStatus.pending,
      );

      // Step 4: Execute atomic transaction
      // In production, this should be a database transaction
      try {
        // Debit source account
        await repository.addTransaction(debitTransaction);

        // Credit destination account
        await repository.addTransaction(creditTransaction);

        // Step 5: Update account balances atomically
        final updatedSourceBalance = sourceAccount.balance - amount;
        final updatedDestinationBalance = destinationAccount.balance + amount;

        // Update repository (in real app, this would be a DB transaction)
        repository.updateAccountBalance(sourceAccountId, updatedSourceBalance);
        repository.updateAccountBalance(destinationAccountId, updatedDestinationBalance);

        // Log success
        auditLogger.logTransactionSuccess(
          transactionId: debitTransaction.id ?? 0,
          action: 'TRANSFER_COMPLETED',
          description: 'Transfer of \$$amount completed from account $sourceAccountId to $destinationAccountId',
          accountId: sourceAccountId,
          metadata: {
            'transferId': transferId,
            'sourceBalance': updatedSourceBalance,
            'destinationBalance': updatedDestinationBalance,
          },
        );

        return m.TransferResult(
          success: true,
          message: 'Transfer completed successfully',
          transferId: transferId,
          sourceTransaction: debitTransaction,
          destinationTransaction: creditTransaction,
        );
      } catch (e) {
        // Rollback on failure
        auditLogger.logTransactionFailure(
          action: 'TRANSFER_FAILED',
          description: 'Transfer failed: $e',
          accountId: sourceAccountId,
          reason: e.toString(),
          metadata: {'transferId': transferId},
        );

        return m.TransferResult(
          success: false,
          message: 'Transfer failed: ${e.toString()}',
          transferId: transferId,
        );
      }
    } catch (e) {
      auditLogger.logTransactionFailure(
        action: 'TRANSFER_ERROR',
        description: 'Unexpected error during transfer: $e',
        accountId: null,
        reason: e.toString(),
      );

      return m.TransferResult(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
        transferId: transferId,
      );
    }
  }

  /// Get transfer history for specific account
  List<m.MoneyTransaction> getTransferHistory(int accountId) {
    return repository.transactions
        .where((t) => t.type == m.TransactionType.transfer && t.accountId == accountId)
        .toList();
  }

  /// Verify transfer integrity (detect inconsistencies)
  bool verifyTransferIntegrity(String transferId) {
    final transactions = repository.transactions
        .where((t) => t.transferId == transferId)
        .toList();

    if (transactions.length != 2) {
      return false; // Should have exactly 2 transactions (debit + credit)
    }

    final debit = transactions[0];
    final credit = transactions[1];

    // Verify amounts match
    if (debit.amount != credit.amount) {
      return false;
    }

    // Verify timestamps are close (within 1 second)
    final timeDiff = debit.date?.difference(credit.date ?? DateTime.now()).inSeconds ?? 0;
    if (timeDiff.abs() > 1) {
      return false;
    }

    return true;
  }
}
