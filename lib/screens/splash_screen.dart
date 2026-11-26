import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onFinished,
  });

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fade;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Membuat animasi fade-in selama 700 milidetik.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    // Mengatur animasi agar muncul secara halus.
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Berpindah ke halaman berikutnya setelah 1,5 detik.
    _timer = Timer(
      const Duration(milliseconds: 1500),
      widget.onFinished,
    );
  }

  @override
  void dispose() {
    // Menghentikan timer ketika halaman ditutup.
    _timer?.cancel();

    // Menghapus controller animasi.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maroon,

      body: Center(
        child: FadeTransition(
          opacity: _fade,

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              // Logo aplikasi.
              const BrandMark(
                light: true,
                showWordmark: false,
              ),

              const SizedBox(height: 18),

              // Nama aplikasi.
              const Text(
                'PKLJOURNEY',

                style: TextStyle(
                  color: AppColors.cream,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}