import 'package:flutter/material.dart';
import 'screens/auth_wrapper.dart';

void main() {
  runApp(const GlassmorphismAuthApp());
}

class GlassmorphismAuthApp extends StatelessWidget {
  const GlassmorphismAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glassmorphism Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}