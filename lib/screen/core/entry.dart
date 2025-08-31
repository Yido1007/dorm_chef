import 'dart:async';
import 'package:dorm_chef/service/boarding.dart';
import 'package:dorm_chef/widget/boarding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dorm_chef/firebase_options.dart';
import 'package:dorm_chef/service/inventory.dart';
import 'package:dorm_chef/screen/core/splash.dart';
import 'package:dorm_chef/screen/core/auth.dart';
import 'package:dorm_chef/screen/home.dart';

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) => const _BootGate();
}

class _BootGate extends StatefulWidget {
  const _BootGate();

  @override
  State<_BootGate> createState() => _BootGateState();
}

class _BootGateState extends State<_BootGate> {
  bool _booting = true;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await Future.wait([
        PantryLocal.boot(), // Hive init + box
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
        GoogleSignIn.instance.initialize(
          serverClientId:
              '318643443437-m6b4hdplov8bj5sigoqu76t30ff5qb7u.apps.googleusercontent.com',
        ),
      ]);
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    } catch (e, st) {
      if (kDebugMode) {
        print('BOOT ERROR: $e\n$st');
      }
    }
    if (!mounted) return;
    setState(() => _booting = false);
  }

  @override
  Widget build(BuildContext context) {
    return _booting ? const SplashScreen() : const _OnboardingGate();
  }
}

class _OnboardingGate extends StatefulWidget {
  const _OnboardingGate();

  @override
  State<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<_OnboardingGate> {
  bool? _seen;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final seen = await OnboardingService.hasSeen();
    if (!mounted) return;
    setState(() => _seen = seen);
  }

  Future<void> _finish() async {
    await OnboardingService.setSeen();
    if (!mounted) return;
    setState(() => _seen = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_seen == null) return const SplashScreen();
    if (_seen == false) {
      return BoardingScreen(onFinished: _finish);
    }
    return const _AuthGate();
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context) {
    final initial = FirebaseAuth.instance.currentUser;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges().distinct(
        (a, b) => a?.uid == b?.uid,
      ),
      initialData: initial,
      builder: (context, snap) {
        final user = snap.data;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child:
              (user == null)
                  ? const AuthScreen(key: ValueKey('auth'))
                  : const HomeScreen(key: ValueKey('home')),
        );
      },
    );
  }
}
