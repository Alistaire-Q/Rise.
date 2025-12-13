import 'models.dart' as m;

class AuditLogger {
  static const String _logPrefix = '[AUDIT]';
  final List<m.AuditLog> _logs = [];

  /// Log a transfer operation
  void logTransfer({
    required int sourceAccountId,
    required int destinationAccountId,
    required double amount,
    required String transferId,
    required String status,
  }) {
    final log = m.AuditLog(
      action: 'TRANSFER_INITIATED',
      description: 'Transfer of \$$amount from account $sourceAccountId to $destinationAccountId',
      accountId: sourceAccountId,
      metadata: {
        'type': 'transfer',
        'sourceAccountId': sourceAccountId,
        'destinationAccountId': destinationAccountId,
        'amount': amount,
        'transferId': transferId,
        'status': status,
      },
    );
    _logs.add(log);
    _printLog(log);
  }

  /// Log transaction success
  void logTransactionSuccess({
    required int transactionId,
    required String action,
    required String description,
    required int accountId,
    Map<String, dynamic>? metadata,
  }) {
    final log = m.AuditLog(
      action: action,
      description: description,
      transactionId: transactionId,
      accountId: accountId,
      metadata: {...?metadata, 'result': 'success'},
    );
    _logs.add(log);
    _printLog(log);
  }

  /// Log transaction failure
  void logTransactionFailure({
    required String action,
    required String description,
    required int? accountId,
    required String reason,
    Map<String, dynamic>? metadata,
  }) {
    final log = m.AuditLog(
      action: action,
      description: description,
      accountId: accountId,
      metadata: {...?metadata, 'result': 'failure', 'reason': reason},
    );
    _logs.add(log);
    _printLog(log);
  }

  /// Log validation errors
  void logValidationError({
    required String description,
    required String errorMessage,
    required int? accountId,
  }) {
    final log = m.AuditLog(
      action: 'VALIDATION_ERROR',
      description: description,
      accountId: accountId,
      metadata: {'error': errorMessage},
    );
    _logs.add(log);
    _printLog(log);
  }

  /// Get all audit logs
  List<m.AuditLog> getLogs() => List.unmodifiable(_logs);

  /// Get logs for specific account
  List<m.AuditLog> getAccountLogs(int accountId) {
    return _logs.where((log) => log.accountId == accountId).toList();
  }

  /// Get logs for specific transaction
  List<m.AuditLog> getTransactionLogs(int transactionId) {
    return _logs.where((log) => log.transactionId == transactionId).toList();
  }

  /// Clear logs (for testing only)
  void clearLogs() => _logs.clear();

  void _printLog(m.AuditLog log) {
    print('$_logPrefix ${log.timestamp.toIso8601String()} - ${log.action}: ${log.description}');
  }
}
