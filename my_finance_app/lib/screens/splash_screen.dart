import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 5), () {});
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECFDF5),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rise Logo
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