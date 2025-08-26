// lib/screen/core/splash.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F8F8), Color(0xFFEFEFEF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Lottie.asset(
              'asset/lottie/Chef.json',
              frameRate: FrameRate.max,
              repeat: true,
            ),
          ),
        ),
      ),
    );
  }
}
