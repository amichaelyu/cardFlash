import 'dart:ui';

import 'package:card_flash/database.dart';
import 'package:card_flash/navBarPages/settingsPage.dart';
import 'package:card_flash/widgets.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'addPage.dart';

class HomeNavigator extends StatelessWidget {
  const HomeNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BetterAppBar(Constants.title, null, null),
      body: const Center(
        child: _HomePage(),
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
        currentIndex: 0,
        // selectedItemColor: Colors.blue[500],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: ((index) {
          switch (index) {
            case 0: {
              break;
            }
            case 1: {
              Navigator.push(
                context,
                PageRouteBuilder(
                  settings: const RouteSettings(name: "/ADD"),
                  pageBuilder: (c, a1, a2) => const AddNavigator(),
                  transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 0),
                ),
              );
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

class _HomePage extends StatelessWidget {

  const _HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Database.getTitles(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 5),
              child: ListView(
                children: [
                  for (var set in snapshot.data) BetterCardHome(set['title'], set['desc'], IconData(set['iconCP'], fontFamily: set['iconFF'], fontPackage: set['iconFP']), set['titleID'], '/HOME/SET')
                ]
            ),
            );
          }
          else if ((snapshot.connectionState == ConnectionState.none) || (snapshot.connectionState == ConnectionState.waiting)) {
            return const Text("");
          }
          else {
            return ListView(children: const [Padding(padding: EdgeInsets.only(top: 20), child: Align(alignment: Alignment.center, child: Text("No sets", style: TextStyle(fontSize: 20,),),),)]);
          }
        }
    );
  }
}