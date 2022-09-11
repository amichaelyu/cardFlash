import 'package:card_flash/constants.dart';
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
    prefs.setInt("currentTitleID", -1);
    prefs.setInt("cardColorLight", Colors.blue.shade200.value);
    prefs.setInt("cardColorDark", Colors.blue.shade900.value);

    // await Future.delayed(const Duration(seconds: 10));

      navigator.push(
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => const HomeNavigator(),
          settings: const RouteSettings(name: "/HOME"),
          transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height * 0.083),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                    Constants.title,
                    style: TextStyle(
                      color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height * 0.059,
                    ),
                  )
            ]
          )
        )
      ]
    );
  }
}