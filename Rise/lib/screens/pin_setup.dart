import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../security_provider.dart';

class PinSetupScreen extends StatefulWidget {
  final VoidCallback onPinSet;

  const PinSetupScreen({Key? key, required this.onPinSet}) : super(key: key);

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _pinCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _errorMsg = '';

  @override
  void dispose() {
    _pinCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _setupPin() async {
    final pin = _pinCtrl.text;
    final confirm = _confirmCtrl.text;

    if (pin.isEmpty || confirm.isEmpty) {
      setState(() => _errorMsg = 'PIN cannot be empty');
      return;
    }

    if (pin.length < 4) {
      setState(() => _errorMsg = 'PIN must be at least 4 digits');
      return;
    }

    if (pin != confirm) {
      setState(() => _errorMsg = 'PINs do not match');
      return;
    }

    final security = Provider.of<SecurityProvider>(context, listen: false);
    final success = await security.setupPin(pin);

    if (success) {
      widget.onPinSet();
    } else {
      setState(() => _errorMsg = 'Failed to set PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Create a 4-digit PIN to secure your app',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMsg.isNotEmpty)
              Text(
                _errorMsg,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _setupPin,
              child: const Text('Set PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
