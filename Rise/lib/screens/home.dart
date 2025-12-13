import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository.dart';
import 'dashboard.dart';
import 'analytics.dart';
import 'add_transaction.dart';
import 'accounts.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // =========================================================================
  // PERUBAHAN DI SINI:
  // Warna Ikon dan Indikator mengikuti warna brand (0xFF043927)
  // =========================================================================
  final Color _brandColor = const Color(0xFF0B3D2E); 
  
  // Warna lain
  final Color limeAccent = const Color(0xFFC5F244); 

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const AccountsScreen(),
    const SettingsScreen(),
  ];

  void _onFabTapped() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        color: Colors.white,
        child: const Center(child: Text("Scan / Add Modal")),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Variabel repo disiapkan untuk akses data jika dibutuhkan di level ini
    final repo = Provider.of<Repository>(context);

    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],

      // 1. Posisi FAB di tengah (Center Docked)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 2. Tombol Tengah (Scan QR) - Tetap Lime Accent sesuai permintaan sebelumnya
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: _onFabTapped,
          backgroundColor: limeAccent, 
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.qr_code, size: 30, color: Colors.black87),
        ),
      ),

      // 3. Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left Side Items
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

              // Spacer untuk memberi ruang pada FAB
              const SizedBox(width: 48),

              // Right Side Items
              _buildNavItem(
                index: 2,
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method untuk item navigasi
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
            // Icon berubah warna sesuai _brandColor (0xFF043927) saat dipilih
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? _brandColor : Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(height: 6),
            
            // Indikator titik (dot) juga mengikuti warna _brandColor
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