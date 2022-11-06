import 'package:card_flash/database.dart';
import 'package:card_flash/navBarPages/settings_page.dart';
import 'package:card_flash/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'add_page.dart';

class HomeNavigator extends StatelessWidget {
  const HomeNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BetterAppBar(Constants.title, null, null, null),
      body: Center(
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

class _HomePage extends StatefulWidget {
  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {

  deleteSet(var snapshot, var index) async {
    Navigator.pop(context);
    await LocalDatabase.deleteSet(snapshot.data[index]['titleID']);
  }

  nav(var titleID) async {
    final navigator = Navigator.of(context);
    (await SharedPreferences.getInstance()).setInt("currentTitleID", titleID);
    await navigator.pushNamed("/HOME/SET");
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: LocalDatabase.getTitles(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 5),
              child: ReorderableListView.builder(
                onReorder: (int oldIndex, int newIndex) async {
                  await LocalDatabase.updatePosition(oldIndex, newIndex, snapshot.data[oldIndex]['titleID']);
                  setState(() {});
                },
                itemBuilder: (BuildContext context, int index) {
                  return Slidable(
                      key: Key(snapshot.data[index]['titleID'].toString()),
                      endActionPane: ActionPane(
                          extentRatio: 0.25,
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('Are you sure you want to delete this set?', semanticsLabel: 'Are you sure you want to delete this set?',),
                                      content: const Text('This process is currently irreversible!', semanticsLabel: 'This process is currently irreversible!',),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel', semanticsLabel: 'Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              deleteSet(snapshot, index);
                                            });
                                          },
                                          child: const Text(
                                            'Confirm',
                                            semanticsLabel: 'Confirm',
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
                          ]
                      ),
                      child: Center(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: InkWell(
                            splashColor: Colors.blue.withAlpha(30),
                            onTap: () {
                              // setState(() {
                                nav(snapshot.data[index]['titleID']);
                              // });
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.95,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(IconData(snapshot.data[index]['iconCP'], fontFamily: snapshot.data[0]['iconFF'] == "" ? null : snapshot.data[0]['iconFF'], fontPackage: snapshot.data[0]['iconFP'] == "" ? null : snapshot.data[0]['iconFP'])),
                                    title: Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text(snapshot.data[index]['title'], semanticsLabel: snapshot.data[index]['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                                    subtitle: Text(snapshot.data[index]['desc'], semanticsLabel: snapshot.data[index]['desc'],),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      TextButton(
                                        child: const Text('STUDY', semanticsLabel: "STUDY",),
                                        onPressed: () async {
                                          final navigator = Navigator.of(context);
                                          (await SharedPreferences.getInstance()).setInt("currentTitleID", snapshot.data[index]['titleID']);
                                          navigator.pushNamed('/HOME/SET/ADAPTIVE');
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    );
                  },
                  itemCount: snapshot.data.length,
              ),
            );
          }
          else if ((snapshot.connectionState == ConnectionState.none) || (snapshot.connectionState == ConnectionState.waiting)) {
            return const Text("", semanticsLabel: "");
          }
          else {
            return ListView(children: [Padding(padding: const EdgeInsets.only(top: 20), child: Align(alignment: Alignment.center, child: Text("No sets", semanticsLabel: "No sets", style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.026,),),),)]);
          }
        }
    );
  }
}