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
        primarySwatch: Colors.blue,
        fontFamily: 'System',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}