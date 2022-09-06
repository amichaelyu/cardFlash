import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets.dart';
import 'addPage.dart';
import 'homePage.dart';

class SettingsNavigator extends StatelessWidget {
  const SettingsNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BetterAppBar(Constants.title, null, null),
      body: const Center(
        child: _SettingsPage(),
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
        currentIndex: 2,
        // selectedItemColor: Colors.blue[500],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: ((index) {
          switch (index) {
            case 0: {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => const HomeNavigator(),
                  transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 0),
                ),
              );
              break;
            }
            case 1: {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => const AddNavigator(),
                  transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 0),
                ),
              );
              break;
            }
            case 2: {
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

class _SettingsPage extends StatelessWidget {

  const _SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Padding(
          padding: EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("rat",
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
      ]
    );
  }
}