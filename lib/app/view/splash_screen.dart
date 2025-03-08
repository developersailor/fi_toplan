import 'dart:async';

import 'package:fi_toplan/app/view/gathering_area_list_view.dart';
import 'package:fi_toplan/app/view/onboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    await Future<void>.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<OnboardScreen>(
          builder: (context) => const OnboardScreen(),
        ),
      );
    } else {
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<GatheringAreaListView>(
          builder: (context) => const GatheringAreaListView(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
