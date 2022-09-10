import 'dart:ui';

import 'package:card_flash/database.dart';
import 'package:card_flash/navBarPages/settingsPage.dart';
import 'package:card_flash/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../constants.dart';
import 'addPage.dart';

class HomeNavigator extends StatelessWidget {
  const HomeNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BetterAppBar(Constants.title, null, null, null),
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
                  for (var set in snapshot.data)
                    Slidable(
                      endActionPane: ActionPane(
                      extentRatio: 0.25,
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                              title: const Text('Are you sure you want to delete this set?'),
                              content: const Text('This process is currently irreversible!'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await Database.deleteSet(set['titleID']);
                                  },
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ));
                          },
                          backgroundColor: const Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete_rounded,
                          label: 'Delete',
                      ),
                    ],
                  ),
                  child: BetterCardHome(set['title'], set['desc'], IconData(set['iconCP'], fontFamily: set['iconFF'], fontPackage: set['iconFP']), set['titleID'], '/HOME/SET', '/HOME/SET/ADAPTIVE')
                )
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