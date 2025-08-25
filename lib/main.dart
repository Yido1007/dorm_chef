import 'package:dorm_chef/firebase_options.dart';
import 'package:dorm_chef/provider/grocery.dart';
import 'package:dorm_chef/screen/core/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:dorm_chef/screen/home.dart';
import 'provider/ingredient.dart';
import 'service/auth.dart';
import 'service/inventory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PantryLocal.boot(); // Hive init + box açılışı
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '318643443437-m6b4hdplov8bj5sigoqu76t30ff5qb7u.apps.googleusercontent.com',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PantryStore()),
        ChangeNotifierProvider(create: (_) => GroceryBag()),
      ],
      child: const DormChefApp(),
    ),
  );
}

class DormChefApp extends StatelessWidget {
  const DormChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: auth.authState(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snap.data == null ? const AuthScreen() : const HomeScreen();
        },
      ),
    );
  }
}
