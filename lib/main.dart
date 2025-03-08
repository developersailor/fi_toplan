import 'package:flutter/material.dart';
import 'package:fi_toplan/theme/theme.dart';
import 'package:fi_toplan/app/view/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gathering Areas',
      theme: const MaterialTheme(TextTheme()).light(),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
