import 'package:card_flash/navBarPages/homePage.dart';
import 'package:card_flash/navBarPages/settingsPage.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets.dart';

class AddNavigator extends StatelessWidget {
  const AddNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BetterAppBar(Constants.title, null, null, null),
      body: const Center(
        child: _AddPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_rounded),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
        currentIndex: 1,
        // selectedItemColor: Colors.blue[500],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: ((index) {
          switch (index) {
            case 0: {
              Navigator.push(
                context,
                PageRouteBuilder(
                  settings: const RouteSettings(name: "/HOME"),
                  pageBuilder: (c, a1, a2) => const HomeNavigator(),
                  transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 0),
                ),
              );
              break;
            }
            case 1: {
              break;
            }
            case 2: {
              Navigator.push(
                context,
                PageRouteBuilder(
                  settings: const RouteSettings(name: "/SETTINGS"),
                  pageBuilder: (c, a1, a2) => const SettingsNavigator(),
                  transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 0),
                ),
              );
              break;
            }
            default:
              break;
          }
        }),
      ),
    );
  }
}

class _AddPage extends StatelessWidget {

  const _AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: ListView(
        children: const [
          BetterCardAdd("Create a Custom Set", "Make your own set from scratch", Icon(Icons.color_lens_rounded), "/ADD/CUSTOM"),
          // BetterCardAdd("Import a Set from Quizlet", "Your set must be public", Text("Q", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25,),), "/HOME/QUIZLET"),
          // BetterCard4("Import a Set using QR", "You can only import other cardFlash sets", Icons.qr_code, "/HOME/QR1"),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Align(
              alignment: Alignment.center,
              child: Text("More options to come!",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ]
      )
    );
  }
}