import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models.dart' as m;
import '../repository.dart';
import '../transfer_service.dart';
import '../audit_logger.dart';
import '../currency_provider.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  int? _sourceAccountId;
  int? _destinationAccountId;
  bool _isTransferring = false;
  String? _transferMessage;
  bool _transferSuccess = false;

  late TransferService _transferService;

  @override
  void initState() {
    super.initState();
    _initializeTransferService();
  }

  void _initializeTransferService() {
    final repo = Provider.of<Repository>(context, listen: false);
    _transferService = TransferService(
      repository: repo,
      auditLogger: AuditLogger(),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _executeTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sourceAccountId == null || _destinationAccountId == null) {
      _showMessage('Please select both accounts', isError: true);
      return;
    }

    setState(() => _isTransferring = true);

    try {
      final amount = double.parse(_amountCtrl.text);

      final result = await _transferService.transferFunds(
        sourceAccountId: _sourceAccountId!,
        destinationAccountId: _destinationAccountId!,
        amount: amount,
        notes: _notesCtrl.text,
      );

      setState(() {
        _transferSuccess = result.success;
        _transferMessage = result.message;
      });

      if (result.success) {
        _showSuccessDialog();
        _resetForm();
      } else {
        _showMessage(result.message, isError: true);
      }
    } catch (e) {
      _showMessage('Transfer failed: $e', isError: true);
    } finally {
      setState(() => _isTransferring = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Transfer Successful'),
        content: const Text('Funds transferred successfully!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _amountCtrl.clear();
    _notesCtrl.clear();
    setState(() {
      _sourceAccountId = null;
      _destinationAccountId = null;
      _transferMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<Repository>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transfer Funds',
                          style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.close, size: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Amount
                    Text('Amount *', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountCtrl,
                      enabled: !_isTransferring,
                      style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.attach_money, color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter amount';
                        final amount = double.tryParse(v);
                        if (amount == null || amount <= 0) return 'Invalid amount';
                        if (amount > m.TransactionValidator.maxTransferLimit) {
                          return 'Exceeds limit: \$${m.TransactionValidator.maxTransferLimit}';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // From Account
                    Text('From Account *', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _sourceAccountId,
                      enabled: !_isTransferring,
                      hint: Text('Select source', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      items: repo.accounts
                          .map((a) => DropdownMenuItem(
                                value: a.id,
                                child: Text('${a.name} (${currencyProvider.formatAmount(a.balance)})'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _sourceAccountId = value;
                          if (value == _destinationAccountId) {
                            _destinationAccountId = null;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                      dropdownColor: Colors.grey[900],
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => v == null ? 'Select source account' : null,
                    ),
                    const SizedBox(height: 16),

                    // To Account
                    Text('To Account *', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _destinationAccountId,
                      enabled: !_isTransferring,
                      hint: Text('Select destination', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      items: repo.accounts
                          .where((a) => a.id != _sourceAccountId)
                          .map((a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(a.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _destinationAccountId = value);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                      dropdownColor: Colors.grey[900],
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => v == null ? 'Select destination account' : null,
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    Text('Notes (Optional)', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesCtrl,
                      enabled: !_isTransferring,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add transfer notes...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isTransferring ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.5)),
                            ),
                            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isTransferring ? null : _executeTransfer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B4D8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isTransferring
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Transfer',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
