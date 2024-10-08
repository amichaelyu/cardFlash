import 'package:card_flash/navBarPages/home_page.dart';
import 'package:card_flash/navBarPages/settings_page.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets.dart';

class AddNavigator extends StatelessWidget {
  const AddNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BetterAppBar(Constants.title, null, null, null),
      body: Center(
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          const BetterCardAdd("Create a Custom Set", "Make your own set from scratch!", Icon(Icons.color_lens_rounded), "/ADD/CUSTOM"),
          BetterCardAdd("Import a Set from Quizlet", "You can only import public sets!", Text("Q", semanticsLabel: "Q", style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.030, fontFamily: "Prompt"),), "/ADD/QUIZLET"),
          const BetterCardAdd("Import a Set using QR", "You can only import other cardFlash sets!", Icon(Icons.qr_code_2_rounded), "/ADD/QR"),
          const BetterCardAdd("Import a Set using Text", "You can only import other cardFlash sets!", Icon(Icons.text_fields_rounded), "/ADD/TEXT_CARDFLASH"),
          // BetterCardAdd("Import Sets from InterSub", "Check them out InterSub.cc!", Text("IS", semanticsLabel: "IS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.030, fontFamily: "NotoSans"),), "/ADD/INTERSUB"),
        ]
      )
    );
  }
}