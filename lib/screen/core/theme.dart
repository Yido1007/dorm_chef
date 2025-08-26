import 'package:flutter/material.dart';

class ThemeChangeScreen extends StatefulWidget {
  const ThemeChangeScreen({super.key});

  @override
  State<ThemeChangeScreen> createState() => _ThemeChangeScreenState();
}

class _ThemeChangeScreenState extends State<ThemeChangeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text("Tema Seçim Ekranı")),
    );
  }
}
