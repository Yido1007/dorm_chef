import 'package:dorm_chef/screen/static/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  String capFirstTr(String s) {
    final t = s.trim();
    if (t.isEmpty) return t;

    // İlk karakteri al (Unicode-güvenli)
    final runes = t.runes.toList();
    final first = String.fromCharCode(runes.first);
    final rest = String.fromCharCodes(runes.skip(1));

    // TR-özel büyük harf
    String upperFirst;
    switch (first) {
      case 'i':
        upperFirst = 'İ';
        break;
      case 'ı':
        upperFirst = 'I';
        break;
      default:
        upperFirst = first.toUpperCase();
    }
    return '$upperFirst$rest';
  }

  String bestDisplayName(User? user, {String fallback = 'Chef'}) {
    if (user == null) return fallback;

    final dn = user.displayName?.trim();
    if (dn != null && dn.isNotEmpty) return dn;

    for (final p in user.providerData) {
      final pdn = p.displayName?.trim();
      if (pdn != null && pdn.isNotEmpty) return pdn;
    }

    final email = user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return fallback;
  }

  String firstName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : fullName;
  }

  @override
  Widget build(BuildContext context) {
    final name = capFirstTr(
      firstName(bestDisplayName(FirebaseAuth.instance.currentUser)),
    );
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snap) {
        final user = snap.data;
        final name = capFirstTr(firstName(bestDisplayName(user)));
        return Scaffold(
          appBar: AppBar(
            title: Text('Merhaba, $name'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1.2,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person),
                    iconSize: 20,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    splashRadius: 22,
                  ),
                ),
              ),
            ],
          ),
          body: Center(child: Text("Home Tab")),
        );
      },
    );
  }
}
