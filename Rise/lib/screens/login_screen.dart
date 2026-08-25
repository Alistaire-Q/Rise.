import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart'; // <--- Paket Baru Wajib Ada

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  bool _isLoading = false;
  late final StreamSubscription<AuthState> _authSubscription;

  // --- WARNA KHUSUS DARI DESAIN ---
  final Color _limeGreen = const Color(0xFFC6E734); // Warna "Grow Your Wealth"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Cek session saat aplikasi dibuka
    _recoverSession();

    // Listener jika status login berubah
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recoverSession();
    }
  }

  Future<void> _recoverSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  // --- FUNGSI LOGIN BARU (NATIVE GOOGLE SIGN IN) ---
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Masukkan Web Client ID yang tadi kamu dapat dari Google Cloud
      const webClientId = 'YOUR_GOOGLE_WEB_CLIENT_ID';

      // 2. Inisialisasi Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      // 3. Buka Jendela Login Native Android
      final googleUser = await googleSignIn.signIn();
      
      // Jika user batal login (tekan back)
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 4. Ambil Token Otentikasi
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'Gagal mendapatkan token dari Google.';
      }

      // 5. Kirim Token ke Supabase (Login sesungguhnya)
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // 6. Sukses! Listener di initState akan otomatis pindah ke /home
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Gagal: $e'), 
            backgroundColor: Colors.red
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kita pakai Stack untuk menumpuk Background Gambar dengan Konten
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE (Full Layar)
          Positioned.fill(
            child: Image.asset(
              'assets/Background.png', // Pastikan file ini ada di folder assets
              fit: BoxFit.cover, // Agar gambar memenuhi layar tanpa gepeng
            ),
          ),

          // 2. KONTEN (Logo, Teks, Tombol)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2), // Pendorong agar konten agak ke atas

                  // --- LOGO ---
                  Image.asset(
                    'assets/Risebg.png', // Logo Rise
                    width: 150, // Sesuaikan ukuran logo (opsional)
                    height: 150,
                  ),
                  
                  const SizedBox(height: 10),

                  // --- JUDUL UTAMA ---
                  const Text(
                    'Rise Finance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat', // Sesuai request
                      fontSize: 48,
                      fontWeight: FontWeight.w800, // ExtraBold/Bold
                      color: Colors.white,
                      height: 1.0, // Rapatkan jarak baris
                    ),
                  ),

                  const SizedBox(height: 8),

                  // --- SUB JUDUL ---
                  Text(
                    'Grow Your Wealth',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat', // Sesuai request
                      fontSize: 24,
                      fontWeight: FontWeight.w500, // Medium
                      color: _limeGreen, // Warna C6E734
                    ),
                  ),

                  const Spacer(flex: 3), // Ruang kosong pendorong tombol ke bawah

                  // --- TOMBOL LOGIN ---
                  _isLoading
                      ? CircularProgressIndicator(color: _limeGreen)
                      : SizedBox(
                          width: double.infinity,
                          height: 55, // Tombol agak tebal biar gagah
                          child: ElevatedButton(
                            onPressed: _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF064E3B), // Hijau Gelap Background Tombol
                              foregroundColor: Colors.white, // Warna Teks
                              elevation: 5,
                              side: BorderSide(color: _limeGreen, width: 1.5), // Border Hijau Muda
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16), // Sudut membulat
                              ),
                            ),
                            child: const Text(
                              'Masuk dengan Google',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 50), // Jarak dari bawah layar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}