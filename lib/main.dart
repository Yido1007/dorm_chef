import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dorm_chef/screen/home.dart';
import 'provider/ingredient.dart';
import 'service/inventory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PantryLocal.boot(); // Hive init + box açılışı
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PantryStore())],
      child: const DormChefApp(),
    ),
  );
}

class DormChefApp extends StatelessWidget {
  const DormChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dorm Chef',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF5E9E5E),
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
