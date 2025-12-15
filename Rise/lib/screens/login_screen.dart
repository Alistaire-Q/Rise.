// lib/screens/login_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Tambahkan "with WidgetsBindingObserver" di sini
class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  bool _isLoading = false;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    // 1. Pasang pengamat gerak-gerik aplikasi (App Lifecycle)
    WidgetsBinding.instance.addObserver(this);
    
    // 2. Cek session saat pertama buka
    _recoverSession();

    // 3. Pasang pendengar Auth (seperti sebelumnya)
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Copot pengamat
    _authSubscription.cancel();
    super.dispose();
  }

  // FUNGSI BARU: Mendeteksi saat aplikasi dibuka kembali dari Browser
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Saat aplikasi 'Resumed' (Aktif lagi), paksa cek session!
      _recoverSession();
    }
  }

  // Fungsi untuk mengecek session secara manual
  Future<void> _recoverSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Perintah Login
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        // Pastikan link ini SAMA PERSIS dengan yang ada di Supabase Dashboard
        redirectTo: 'io.supabase.rise://login-callback', 
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Kita tidak matikan loading di sini agar user tidak bisa klik 2x
      // Loading akan mati sendiri kalau pindah halaman
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.savings_outlined, size: 100, color: Color(0xFF059669)),
              const SizedBox(height: 20),
              
              const Text(
                'Rise Finance',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Kelola keuanganmu dengan bijak'),
              const SizedBox(height: 40),

              _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF059669))
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: const Icon(Icons.login),
                        label: const Text('Masuk dengan Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}