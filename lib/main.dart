import 'package:dorm_chef/provider/ingredient.dart';
import 'package:dorm_chef/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const DormChefApp());
}

class DormChefApp extends StatelessWidget {
  const DormChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => InventoryProvider())],
      child: MaterialApp(
        title: 'Dorm Chef',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color.fromARGB(255, 3, 106, 124),
          brightness: Brightness.light,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
