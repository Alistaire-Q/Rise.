import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class SecurityProvider extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  late SharedPreferences _prefs;

  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  bool get biometricEnabled => _biometricEnabled;
  bool get biometricAvailable => _biometricAvailable;

  Future init() async {
    _prefs = await SharedPreferences.getInstance();
    _biometricEnabled = _prefs.getBool('biometric_enabled') ?? false;

    // Check if biometric is available
    try {
      _biometricAvailable = await _localAuth.canCheckBiometrics;
    } catch (e) {
      _biometricAvailable = false;
    }

    notifyListeners();
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    await _prefs.setBool('biometric_enabled', enabled);
    notifyListeners();
    return true;
  }

  Future<bool> authenticateWithBiometric() async {
    if (!_biometricAvailable || !_biometricEnabled) return false;
    try {
      final result = await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock MyFinanceApp',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return result;
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      return false;
    }
  }

  Future<void> clearBiometric() async {
    _biometricEnabled = false;
    await _prefs.setBool('biometric_enabled', false);
    notifyListeners();
  }
}
