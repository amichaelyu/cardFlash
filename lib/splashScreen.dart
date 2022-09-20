import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database.dart';
import 'navBarPages/homePage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  _readDB() async {
    final navigator = Navigator.of(context);
    await Database.initializeDB();
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getInt("currentTitleID") == null) {
      await prefs.setInt("currentTitleID", -1);
    }
    if (prefs.getInt("cardColorLight") == null) {
      await prefs.setInt("cardColorLight", Colors.blue.shade200.value);
    }
    if (prefs.getInt("cardColorDark") == null) {
      await prefs.setInt("cardColorDark", Colors.blue.shade900.value);
    }
    if (prefs.getBool("adaptivePrompt") == null) {
      prefs.setBool("adaptivePrompt", true);
    }
    if (prefs.getBool("adaptiveInstant") == null) {
      prefs.setBool("adaptiveInstant", true);
    }

    // await Future.delayed(const Duration(seconds: 10));

      navigator.push(
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => const HomeNavigator(),
          settings: const RouteSettings(name: "/HOME"),
          transitionDuration: Duration.zero,
        )
      );
  }

  @override
  void initState() {
    super.initState();
    _readDB();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('');
  }
}