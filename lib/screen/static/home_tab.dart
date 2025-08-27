import 'package:dorm_chef/screen/static/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName = (user?.displayName ?? '')
        .split(' ')
        .firstWhere((e) => e.isNotEmpty, orElse: () => '');
    return Scaffold(
      appBar: AppBar(
        title: const Text('DormChef'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black45, width: 1.2),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingScreen()),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(firstName.isEmpty ? 'DormChef' : 'Merhaba, $firstName'),
        ],
      ),
    );
  }
}
