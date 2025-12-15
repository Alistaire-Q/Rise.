import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Import Supabase

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate(); // Nama fungsi saya perjelas sedikit
  }

  // Logika Navigasi Baru
  _checkAuthAndNavigate() async {
    // 1. Tetap tunggu 5 detik sesuai kode aslimu
    await Future.delayed(const Duration(seconds: 5), () {});

    // 2. Cek apakah user sudah login di Supabase?
    final session = Supabase.instance.client.auth.currentSession;

    if (mounted) {
      if (session != null) {
        // KASUS A: Sudah Login -> Masuk ke Home (seperti biasa)
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // KASUS B: Belum Login -> Arahkan ke Login Screen
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Desain tetap Putih
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rise Logo (Tetap Sama)
            Image.asset(
              'Rise.png',
              width: 500,
              height: 500,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}