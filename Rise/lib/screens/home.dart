import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository.dart';
import 'dashboard.dart';
import 'analytics.dart';
import 'add_transaction.dart';
import 'accounts.dart';
import 'settings.dart';
import 'package:rise/models.dart' as m;
import 'scan_receipt_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final Color _brandColor = const Color(0xFF0B3D2E);
  final Color limeAccent = const Color(0xFFC5F244);

  // List Screen
  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const SizedBox.shrink(), // Placeholder untuk Kamera (index 2)
    const AccountsScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) async {
    // Logika Khusus Kamera (Index 2)
    if (index == 2) {
      final result = await Navigator.push<double>(
        context,
        MaterialPageRoute(builder: (_) => const ScanReceiptScreen()),
      );

      // Cek apakah widget masih aktif (mounted) sebelum lanjut
      if (!mounted) return;

      final amount = result ?? 0.0;
      if (amount > 0) {
        showDialog(
          context: context,
          builder: (context) => AddTransactionScreen(
            initialType: m.TransactionType.expense,
            initialAmount: amount,
            initialAmountString: amount.toStringAsFixed(0), // Hilangkan desimal .00 agar rapi
            initialMerchant: null,
            initialDate: null,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No amount detected from receipt.')),
        );
      }
      return;
    }

    // Logika Pindah Tab Biasa
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kita panggil Provider di sini meski tidak dipakai langsung di build,
    // untuk memastikan update state repository tertangkap.
    Provider.of<Repository>(context);

    return Scaffold(
      extendBody: true, // Agar konten menyatu dengan area bawah (opsional)
      body: _screens[_selectedIndex],

      // Custom Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, -3),
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Kiri
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                ),

                // Tengah (Tombol Kamera Melayang)
                Transform.translate(
                  offset: const Offset(0, -20), // Angkat sedikit ke atas
                  child: InkWell(
                    onTap: () => _onItemTapped(2),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: limeAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(Icons.camera_alt, size: 30, color: Colors.black87),
                    ),
                  ),
                ),

                // Kanan
                _buildNavItem(
                  index: 3,
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Navigasi
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? _brandColor : Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: _brandColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}