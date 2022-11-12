import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../widgets.dart';
import 'add_page.dart';
import 'home_page.dart';

class SettingsNavigator extends StatelessWidget {
  const SettingsNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BetterAppBar(Constants.title, null, null, null),
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
  const _SettingsPage();

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  // @override
  // State<_SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<_SettingsPage> {
  final Uri _developer = Uri.parse('https://github.com/itsmichaelyu');
  final Uri _privacyPolicy = Uri.parse('https://github.com/itsmichaelyu/cardFlash/blob/master/PRIVACY.md');
  final Uri _bugReport = Uri.parse('https://itsmichaelyu.github.io/cardFlashBug/');
  final Uri _featureRequest = Uri.parse('https://itsmichaelyu.github.io/cardFlashFeature/');
  final Uri _betaTester = Uri.parse('https://itsmichaelyu.github.io/cardFlashBeta');
  late bool adaptiveInstant;
  late bool haptics;
  late String version;

  _readPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    adaptiveInstant = prefs.getBool("adaptiveInstant")!;
    haptics = prefs.getBool("haptics")!;
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
                  const Text("Settings", semanticsLabel: "Settings", textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Center(
                    child: Card(
                      color: adaptiveInstant ? Colors.green : Colors.red,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () async {
                          adaptiveInstant = !adaptiveInstant;
                          await (await SharedPreferences.getInstance()).setBool("adaptiveInstant", adaptiveInstant);
                          setState(() {});
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.77,
                          height: MediaQuery.of(context).size.height * 0.071,
                          child: Padding(padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.020, 0, 0), child: Text("Adaptive Instant ${adaptiveInstant ? "Enabled" : "Disabled"}", semanticsLabel: "Adaptive Instant ${adaptiveInstant ? "Enabled" : "Disabled"}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Center(
                    child: Card(
                      color: haptics ? Colors.green : Colors.red,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () async {
                          haptics = !haptics;
                          if (haptics) HapticFeedback.heavyImpact();
                          await (await SharedPreferences.getInstance()).setBool("haptics", haptics);
                          setState(() {});
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.77,
                          height: MediaQuery.of(context).size.height * 0.071,
                          child: Padding(padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.020, 0, 0), child: Text("Haptics ${haptics ? "Enabled" : "Disabled"}", semanticsLabel: "Haptics ${haptics ? "Enabled" : "Disabled"}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 15),
                  ),
                  const Text("About", semanticsLabel: "About", textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  BetterCardSettings("Version: ${Constants.version}", null, null),
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
                  // BetterCardSettings("Become a Beta Tester",
                  //         () async {
                  //       if (!await launchUrl(_betaTester)) {
                  //         throw 'Could not launch $_betaTester';
                  //       }
                  //     }, MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade800),
                  const Padding(
                    padding: EdgeInsets.only(top: 15),
                  ),
                  const Text("Legal", semanticsLabel: "Legal", textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
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
                  const Text("Reset", semanticsLabel: "Reset", textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  BetterCardSettings("Reset App",
                          () {showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Are you sure you want to reset the app?', semanticsLabel: "Are you sure you want to reset the app?"),
                          content: const Text('This process is irreversible!', semanticsLabel: "This process is irreversible!"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel', semanticsLabel: "Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                await (await SharedPreferences.getInstance()).setBool("rebirth", true);
                                if (!mounted) return;
                                Phoenix.rebirth(context);
                              },
                              child: const Text(
                                'Confirm',
                                semanticsLabel: "Confirm",
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
                body: const Text('', semanticsLabel: ''));
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
                body: Column(children: [
                  Padding(padding: const EdgeInsets.only(top: 20),
                    child: Align(alignment: Alignment.center,
                      child: Text("Something went wrong :(",
                        semanticsLabel: "Something went wrong",
                        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.024,),),),)
                ])
            );
          }
        }
    );
  }
}