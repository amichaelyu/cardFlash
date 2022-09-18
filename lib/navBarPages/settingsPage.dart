import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../database.dart';
import '../widgets.dart';
import 'addPage.dart';
import 'homePage.dart';

class SettingsNavigator extends StatelessWidget {
  const SettingsNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BetterAppBar(Constants.title, null, null, null),
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
                  settings: const RouteSettings(name: "/HOME"),
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
                  settings: const RouteSettings(name: "/ADD"),
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

class _SettingsPage extends StatefulWidget {
  const _SettingsPage({super.key});

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  // @override
  // State<_SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<_SettingsPage> {
  final Uri _developer = Uri.parse('https://github.com/itsmichaelyu');
  final Uri _privacyPolicy = Uri.parse('https://github.com/itsmichaelyu/cardFlashBugs/blob/master/PRIVACY.md');
  final Uri _bugReport = Uri.parse('https://itsmichaelyu.github.io/cardFlashBug/');
  final Uri _featureRequest = Uri.parse('https://itsmichaelyu.github.io/cardFlashFeature/');
  final Uri _betaTester = Uri.parse('https://itsmichaelyu.github.io/cardFlashBeta');
  late bool adaptivePrompt = true;

  _readPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    adaptivePrompt = prefs.getBool("adaptivePrompt")!;
  }

  @override
  void initState() {
    super.initState();
    _readPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                  ),
                  const Text("Settings", textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Center(
                    child: Card(
                      color: adaptivePrompt ? Colors.green : Colors.red,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () async {
                          adaptivePrompt = !adaptivePrompt;
                          await (await SharedPreferences.getInstance()).setBool("adaptivePrompt", adaptivePrompt);
                          setState(() {});
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.77,
                          height: MediaQuery.of(context).size.height * 0.071,
                          child: Padding(padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.020, 0, 0), child: Text("Adaptive Prompts ${adaptivePrompt ? "Enabled" : "Disabled"}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 15),
                  ),
                  const Text("About", textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  const BetterCardSettings("Version: ${Constants.version}", null, null),
                  BetterCardSettings("Developer: Michael Yu",
                          () async {
                        if (!await launchUrl(_developer)) {
                          throw 'Could not launch $_developer';
                        }}, MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade800),
                  BetterCardSettings("Report a Bug",
                          () async {
                        if (!await launchUrl(_bugReport)) {
                          throw 'Could not launch $_bugReport';
                        }
                      }, MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade800),
                  BetterCardSettings("Request a Feature",
                          () async {
                        if (!await launchUrl(_featureRequest)) {
                          throw 'Could not launch $_featureRequest';
                        }
                      }, MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade800),
                  BetterCardSettings("Become a Beta Tester",
                          () async {
                        if (!await launchUrl(_betaTester)) {
                          throw 'Could not launch $_betaTester';
                        }
                      }, MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade800),
                  const Padding(
                    padding: EdgeInsets.only(top: 15),
                  ),
                  const Text("Legal", textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  BetterCardSettings("Privacy Policy",
                          () async {
                        if (!await launchUrl(_privacyPolicy)) {
                          throw 'Could not launch $_privacyPolicy';
                        }
                      }, MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade800),
                  BetterCardSettings("Licenses", () {
                    showLicensePage(context: context);
                  }, MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade800),
                  const Padding(
                    padding: EdgeInsets.only(top: 15),
                  ),
                  const Text("Reset", textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  BetterCardSettings("Reset App",
                          () {showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Are you sure you want to reset the app?'),
                          content: const Text('This process is irreversible!'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await Database.clearTables();
                                await (await SharedPreferences.getInstance()).setBool('adaptivePrompt', true);
                                adaptivePrompt = true;
                                setState(() {});
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );}, MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade800),
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                  ),
                ]
            );
          }
          else if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
            return const Text('');
          }
          else {
            return Scaffold(
                appBar: BetterAppBar(Constants.title, null, Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                      ),
                    )
                ),null),
                body: ListView(children: [
                  Padding(padding: const EdgeInsets.only(top: 20),
                    child: Align(alignment: Alignment.center,
                      child: Text("Something went wrong :(",
                        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.024,),),),)
                ])
            );
          }
        }
    );
  }
}