import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../currency_provider.dart';
import 'package:rise/models.dart' as m;

// Hapus import security_provider dan security_settings karena fiturnya dihilangkan

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Warna Tema
  final Color _primaryDark = const Color(0xFF000000); // Black (Judul)
  final Color _iconColor = const Color(0xFFC5F244); // Lime Green (Icon Aksen)
  final Color _textSecondary = const Color(0xFF757575); // Abu-abu (Subtitle)

  void _showCurrencyDialog(BuildContext context, CurrencyProvider currencyProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Select Currency',
            style: TextStyle(color: _primaryDark, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: m.Currency.values.map((currency) {
              return RadioListTile<m.Currency>(
                activeColor: _primaryDark,
                title: Text('${currency.code.toUpperCase()} (${currency.symbol})'),
                subtitle: currency == m.Currency.idr
                    ? const Text('1 USD = 16,000 IDR')
                    : const Text('Base currency'),
                value: currency,
                groupValue: currencyProvider.selectedCurrency,
                onChanged: (m.Currency? value) {
                  if (value != null) {
                    currencyProvider.setCurrency(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: _textSecondary)),
            ),
          ],
        );
      },
    );
  }

  // Widget Helper untuk Item Setting agar kode lebih rapi
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9), // Hijau sangat pudar untuk background icon
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _primaryDark), // Menggunakan Dark Green agar kontras di background terang
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: _textSecondary, fontSize: 13),
            )
          : null,
      trailing: Icon(Icons.chevron_right, color: _textSecondary),
      onTap: onTap,
    );
  }

  // Widget Helper untuk Judul Section (Preferences, Support, dll)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: _textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white, // Full White Background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Settings',
          style: TextStyle(
            color: _primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        iconTheme: IconThemeData(color: _primaryDark), // Warna tombol back
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        children: [
          // --- SECTION 1: PREFERENCES ---
          _buildSectionHeader('PREFERENCES'),
          
          _buildSettingItem(
            icon: Icons.monetization_on_outlined,
            title: 'Currency',
            subtitle: 'Selected: ${currencyProvider.selectedCurrency.code.toUpperCase()} (${currencyProvider.selectedCurrency.symbol})',
            onTap: () => _showCurrencyDialog(context, currencyProvider),
          ),

          // --- SECTION 2: SUPPORT & INFO ---
          _buildSectionHeader('SUPPORT & INFO'),

          _buildSettingItem(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Feedback',
            subtitle: 'Send us your thoughts',
            onTap: () {
              // Simulasi aksi feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening feedback form...')),
              );
            },
          ),
          
          _buildSettingItem(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            subtitle: 'qolbysumarrasatriawan@gmail.com', // Email support
            onTap: () {
              // Simulasi aksi email
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Contact Support'),
                  content: const Text('Would you like to send an email to qolbysumarrasatriawan@gmail.com?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                         Navigator.pop(ctx);
                         ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening email app...')),
                         );
                      },
                      child: const Text('Open Email'),
                    ),
                  ],
                ),
              );
            },
          ),

          _buildSettingItem(
            icon: Icons.info_outline_rounded,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Rise Finance',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Rise App. All rights reserved.',
                applicationIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryDark,
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: const Icon(Icons.eco, color: Colors.white),
                )
              );
            },
          ),
        ],
      ),
    );
  }
}