import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../security_provider.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final security = Provider.of<SecurityProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Biometric'),
              subtitle: Text(security.biometricAvailable ? 'Available' : 'Not available on device'),
              value: security.biometricEnabled && security.biometricAvailable,
              onChanged: security.biometricAvailable
                  ? (v) async {
                      await security.setBiometricEnabled(v);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
