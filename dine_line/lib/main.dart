// file: lib/main.dart

import 'package:flutter/material.dart';
import 'splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dineline',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB9191E), // ACJC Red
          primary: const Color(0xFFB9191E), // ACJC Red
          secondary: const Color(0xFF2F4293), // ACJC Blue
          tertiary: const Color(0xFFFEB303), // ACJC Gold
          surface: const Color(0xFFFFF8F6), // Light background
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onTertiary: Colors.black,
        ),
        fontFamily: 'System',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}