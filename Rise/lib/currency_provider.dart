import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'models.dart' as m;

class CurrencyProvider extends ChangeNotifier {
  m.Currency _selectedCurrency = m.Currency.usd;

  m.Currency get selectedCurrency => _selectedCurrency;

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currencyString = prefs.getString('selectedCurrency') ?? 'usd';
      _selectedCurrency = m.Currency.fromString(currencyString);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading currency: $e');
    }
  }

  Future<void> setCurrency(m.Currency currency) async {
    if (_selectedCurrency == currency) return;
    
    _selectedCurrency = currency;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedCurrency', currency.code.toLowerCase());
    } catch (e) {
      debugPrint('Error saving currency: $e');
    }
  }

  void toggleCurrency() {
    if (_selectedCurrency == m.Currency.usd) {
      setCurrency(m.Currency.idr);
    } else {
      setCurrency(m.Currency.usd);
    }
  }

  // Format amount dengan konversi otomatis
  String formatAmount(double amountInUsd) {
    double convertedAmount = amountInUsd * _selectedCurrency.exchangeRate;
    
    if (_selectedCurrency == m.Currency.idr) {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: _selectedCurrency.symbol,
        decimalDigits: 0
      ).format(convertedAmount);
    } else {
      return NumberFormat.currency(
        locale: 'en_US',
        symbol: _selectedCurrency.symbol,
        decimalDigits: 2
      ).format(convertedAmount);
    }
  }

  // Konversi dari mata uang aktif ke USD (untuk save ke database)
  double convertToUsd(double amountInLocalCurrency) {
    return amountInLocalCurrency / _selectedCurrency.exchangeRate;
  }
}