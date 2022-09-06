import 'package:card_flash/constants.dart';
import 'package:card_flash/main.dart';
import 'package:card_flash/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database.dart';

class SplashPage extends StatefulWidget {
  const SplashPage.SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  _readDB() async {
    await Database.initializeDB();
    (await SharedPreferences.getInstance()).setInt("currentSet", -1);

    // await Future.delayed(const Duration(seconds: 10));
    // await Database.insertSet(CardSet(0, "AP Chemistry", "Weird Set", Icons.science_rounded, ["acetate", "suitcase/luggage", "What kind of ticket would you like?", "Charles I"], ["C₂H₃O₂⁻", "une valise", "quelle sorte de billet désirez-vous?", "King of England and son of James I. His power struggles with Parliament resulted in the English Civil War (1642-1648) in which he was defeated, tried for treason and beheaded in 1649"]));

    setState(() {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => const HomeNavigator(),
          transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _readDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 70),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                    Constants.title,
                    style: TextStyle(
                      color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                    ),
                  )
            ]
          )
        )
      ]
    );
  }
}