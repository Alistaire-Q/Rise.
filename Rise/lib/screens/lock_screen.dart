import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../security_provider.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({Key? key, required this.onUnlocked}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _enteredPin = '';
  bool _showError = false;

  void _addDigit(String digit) {
    setState(() {
      if (_enteredPin.length < 6) {
        _enteredPin += digit;
        _showError = false;
      }
    });

    if (_enteredPin.length == 4) {
      _attemptUnlock();
    }
  }

  void _removeDigit() {
    setState(() {
      if (_enteredPin.isNotEmpty) {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _showError = false;
      }
    });
  }

  Future<void> _attemptUnlock() async {
    final security = Provider.of<SecurityProvider>(context, listen: false);
    final success = await security.authenticateWithPin(_enteredPin);

    if (success) {
      widget.onUnlocked();
    } else {
      setState(() {
        _showError = true;
        _enteredPin = '';
      });
    }
  }

  Future<void> _attemptBiometric() async {
    final security = Provider.of<SecurityProvider>(context, listen: false);
    final success = await security.authenticateWithBiometric();
    if (success) {
      widget.onUnlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    final security = Provider.of<SecurityProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text('Enter PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (i) => Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _enteredPin.length ? Colors.blue : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_showError)
              const Text('Incorrect PIN', style: TextStyle(color: Colors.red, fontSize: 14))
            else
              const SizedBox(height: 20),
            const SizedBox(height: 24),
            // PIN Pad
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              childAspectRatio: 1.5,
              children: List.generate(9, (i) {
                final digit = (i + 1).toString();
                return _buildPinButton(digit, () => _addDigit(digit));
              }) +
                  [
                    _buildPinButton('', () {}),
                    _buildPinButton('0', () => _addDigit('0')),
                    _buildPinButton('⌫', _removeDigit, isDelete: true),
                  ],
            ),
            const SizedBox(height: 24),
            if (security.biometricAvailable && security.biometricEnabled)
              ElevatedButton.icon(
                onPressed: _attemptBiometric,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Use Biometric'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinButton(String label, VoidCallback onTap, {bool isDelete = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: label.isEmpty ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDelete ? Colors.red : Colors.blue,
          disabledBackgroundColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 20, color: label.isEmpty ? Colors.transparent : Colors.white),
        ),
      ),
    );
  }
}
