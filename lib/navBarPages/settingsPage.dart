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
      body: Center(
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

class _SettingsPage extends StatelessWidget {
  // @override
  // State<_SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<_SettingsPage> {
  final Uri _developer = Uri.parse('https://github.com/itsmichaelyu');
  final Uri _privacyPolicy = Uri.parse('https://github.com/itsmichaelyu/cardFlashBugs/blob/master/PRIVACY.md');
  final Uri _bugReport = Uri.parse('https://github.com/itsmichaelyu/cardFlashBugs/issues/new?assignees=itsmichaelyu&labels=bug&template=bug_report.md&title=');
  final Uri _featureRequest = Uri.parse('https://github.com/itsmichaelyu/cardFlashBugs/issues/new?assignees=itsmichaelyu&labels=feature&template=feature_request.md&title=');
  final Uri _betaTester = Uri.parse('https://itsmichaelyu.github.io/cardFlashBeta');

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20),
        ),
        const Text("About", textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        const BetterCardSettings("Version: ${Constants.version}", null, null),
        const BetterCardSettings("Branch: ${Constants.beta ? "Beta" : "Release"}", null, null),
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
        BetterCardSettings("Request a feature",
                () async {
              if (!await launchUrl(_featureRequest)) {
                throw 'Could not launch $_featureRequest';
              }
            }, MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade800),
        BetterCardSettings("Become a beta tester",
                () async {
              if (!await launchUrl(_betaTester)) {
                throw 'Could not launch $_betaTester';
              }
            }, MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade800),
        const Padding(
          padding: EdgeInsets.only(top: 20),
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
          padding: EdgeInsets.only(top: 20),
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
}