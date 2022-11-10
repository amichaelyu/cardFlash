import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart' as db;
import 'navBarPages/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  _readDB() async {
    final navigator = Navigator.of(context);
    var prefs = await SharedPreferences.getInstance();
    bool rebirth = prefs.getBool('rebirth') ?? false;
    if (rebirth) {
      await prefs.clear();
      await databaseFactory.deleteDatabase('sets.db');
    }
    if (prefs.getInt("currentTitleID") == null) {
      await prefs.setInt("currentTitleID", -1);
    }
    if (prefs.getInt("currentTitleID") == null) {
      await prefs.setInt("currentTitleID", -1);
    }
    if (prefs.getInt("cardColorLight") == null) {
      await prefs.setInt("cardColorLight", Colors.blue.shade200.value);
    }
    if (prefs.getInt("cardColorDark") == null) {
      await prefs.setInt("cardColorDark", Colors.blue.shade900.value);
    }
    if (prefs.getBool("adaptiveInstant") == null) {
      prefs.setBool("adaptiveInstant", true);
    }
    if (prefs.getBool("haptics") == null) {
      prefs.setBool("haptics", true);
    }
    await db.LocalDatabase.initializeDB();
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
    return const Text('', semanticsLabel: '',);
  }
}