import 'package:card_flash/setPage/setPage.dart';
import 'package:card_flash/splashScreen.dart';
import 'package:card_flash/widgets.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'navBarPages/addSubpages/QRImportPage1.dart';
import 'navBarPages/addSubpages/QRImportPage2.dart';
import 'navBarPages/addSubpages/customAddPage.dart';
import 'navBarPages/addSubpages/quizletImportPage.dart';
import 'navBarPages/settingsPage.dart';
import 'setPage/editPage.dart';
import 'setPage/modes/adaptivePage.dart';
import 'setPage/modes/flashcardPage.dart';
import 'navBarPages/addPage.dart';
import 'navBarPages/homePage.dart';

void main() async => runApp(
    MaterialApp(
      title: Constants.title,
      theme: FlexThemeData.light(
        scheme: FlexScheme.brandBlue,
        fontFamily: "Roboto",
      ),
      darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.brandBlue,
          fontFamily: "Roboto",
          // darkIsTrueBlack: true
      ),
      themeMode: ThemeMode.system,
      /* ThemeMode.system to follow system theme,
         ThemeMode.light for light theme,
         ThemeMode.dark for dark theme
      */
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage.SplashPage(),
        '/HOME': (context) => const HomePage(),
        '/HOME/SET': (context) => const SetPage(),
        '/HOME/SET/FLASHCARDS': (context) => const FlashcardPage(),
        '/HOME/SET/ADAPTIVE': (context) => const AdaptivePage(),
        '/HOME/SET/EDIT': (context) => EditPage(),
        '/ADD': (context) => const AddPage(),
        '/ADD/CUSTOM': (context) => const CustomAddPage(),
        '/ADD/QR1': (context) => const QRImportPage1(),
        '/ADD/QR1/QR2': (context) => const QRImportPage2(),
        '/ADD/QUIZLET': (context) => const QuizletImportPage(),
        '/SETTINGS': (context) => const SettingsPage(),
      },
    )
);

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const AddPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setHome() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BetterAppBar(Constants.title, null, null),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
        currentIndex: _selectedIndex,
        // selectedItemColor: Colors.blue[500],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
      ),
    );
  }
}