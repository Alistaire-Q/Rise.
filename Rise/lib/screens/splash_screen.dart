import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart'; // 1. Wajib Import Video Player

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    // 2. Load Video dari Assets (intro.mp4)
    _controller = VideoPlayerController.asset('assets/intro.mp4')
      ..initialize().then((_) {
        // Refresh layar agar video muncul setelah siap
        setState(() {});
        
        _controller.setVolume(0.0); // Mute suara (opsional)
        _controller.play(); // Mulai putar
      });

    // 3. Pasang 'Satpam' (Listener) untuk memantau durasi video
    _controller.addListener(() {
      // Jika video sudah sampai akhir DAN belum ditandai selesai
      if (_controller.value.position >= _controller.value.duration) {
        if (!_isVideoCompleted) {
          _isVideoCompleted = true;
          _checkAuthAndNavigate(); // Panggil fungsi cek login
        }
      }
    });
  }

  // 4. Logika Cek Login (Dipanggil otomatis saat video selesai)
  Future<void> _checkAuthAndNavigate() async {
    // Sedikit jeda agar transisi tidak kasar
    await Future.delayed(const Duration(milliseconds: 300));

    // Cek status login Supabase
    final session = Supabase.instance.client.auth.currentSession;

    if (mounted) {
      if (session != null) {
        // KASUS A: Sudah Login -> Masuk ke Home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // KASUS B: Belum Login -> Arahkan ke Login Screen
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Wajib matikan video player saat pindah halaman
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background Putih (Menyatu dengan video)
      body: Center(
        // Cek apakah video sudah siap?
        child: _controller.value.isInitialized
            ? AspectRatio(
                // Menjaga rasio video tetap 1:1 (Kotak)
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const SizedBox(), // Tampilan kosong bersih saat loading awal
      ),
    );
  }
}