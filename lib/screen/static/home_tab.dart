import 'package:dorm_chef/provider/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../service/auth.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: Column(
        children: [
          const Center(child: Text('Hoş geldin!')),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              AuthService().signOut();
              await context.read<PantryStore>().unbind();
            },
          ),
        ],
      ),
    );
  }
}
