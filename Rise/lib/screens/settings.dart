import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // 1. Wajib Import ini
import '../currency_provider.dart';
import 'package:rise/models.dart' as m;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color _primaryDark = const Color(0xFF000000); 
  final Color _textSecondary = const Color(0xFF757575); 

  // --- FUNGSI KIRIM EMAIL (BARU) ---
  Future<void> _sendEmail({required String subject, String body = ''}) async {
    // Alamat email tujuan (Email Kamu)
    final String recipientEmail = 'qolbysumarrasatriawan@gmail.com';

    // Membuat URL mailto yang aman (mengubah spasi jadi kode %20, dll)
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: recipientEmail,
      query: _encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      // Jika di HP tidak ada aplikasi email / error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email app.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper untuk encode karakter khusus di URL
  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // --- FUNGSI LOGOUT ---
  Future<void> _signOut() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error signing out: $e')),
          );
        }
      }
    }
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Totals may vary due to currency conversion.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 12),
              ...m.Currency.values.map((currency) {
                return RadioListTile<m.Currency>(
                  activeColor: _primaryDark,
                  contentPadding: EdgeInsets.zero,
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
            ],
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

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? customIconColor,
    Color? customTextColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: customIconColor == Colors.red 
              ? Colors.red.withOpacity(0.1) 
              : const Color(0xFFF1F8E9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: customIconColor ?? _primaryDark),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: customTextColor ?? Colors.black87,
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
      backgroundColor: Colors.white,
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
        iconTheme: IconThemeData(color: _primaryDark),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        children: [
          _buildSectionHeader('PREFERENCES'),
          
          _buildSettingItem(
            icon: Icons.monetization_on_outlined,
            title: 'Currency',
            subtitle: 'Selected: ${currencyProvider.selectedCurrency.code.toUpperCase()} (${currencyProvider.selectedCurrency.symbol})',
            onTap: () => _showCurrencyDialog(context, currencyProvider),
          ),

          _buildSectionHeader('SUPPORT & INFO'),

          // --- 1. UPDATE TOMBOL FEEDBACK ---
          _buildSettingItem(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Feedback',
            subtitle: 'Send us your thoughts',
            onTap: () {
              // Langsung buka Email dengan Subjek Feedback
              _sendEmail(
                subject: 'Feedback Aplikasi Rise', 
                body: 'Halo Admin,\n\nSaya ingin memberi masukan tentang aplikasi ini:\n\n'
              );
            },
          ),
          
          // --- 2. UPDATE TOMBOL HELP CENTER ---
          _buildSettingItem(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            subtitle: 'Contact support via Email',
            onTap: () {
               // Langsung buka Email dengan Subjek Bantuan
               _sendEmail(
                subject: 'Butuh Bantuan - Rise Finance',
                body: 'Halo Admin,\n\nSaya mengalami masalah pada bagian:\n\n'
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

          _buildSectionHeader('ACCOUNT'),

          _buildSettingItem(
            icon: Icons.logout_rounded,
            title: 'Log Out',
            subtitle: 'Sign out from your account',
            customIconColor: Colors.red,
            customTextColor: Colors.red,
            onTap: _signOut,
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}