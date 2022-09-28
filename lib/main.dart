import 'package:card_flash/setPage/modes/adaptivePageSettings.dart';
import 'package:card_flash/setPage/setPage.dart';
import 'package:card_flash/splashScreen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String appName = packageInfo.appName;
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;

  Constants.setConstants(appName, "$version+$buildNumber");

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      Phoenix(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
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
            '/': (context) => const SplashPage(),
            '/HOME': (context) => const HomeNavigator(),
            '/HOME/SET': (context) => const SetPage(),
            '/HOME/SET/FLASHCARDS': (context) => const FlashcardPage(),
            '/HOME/SET/ADAPTIVE': (context) => const AdaptivePage(),
            '/HOME/SET/ADAPTIVE/SETTINGS': (context) => const AdaptiveSettingsPage(),
            '/HOME/SET/EDIT': (context) => const EditPage(),
            '/ADD': (context) => const AddNavigator(),
            '/ADD/CUSTOM': (context) => const CustomAddPage(),
            '/ADD/QR1': (context) => const QRImportPage1(),
            '/ADD/QR1/QR2': (context) => const QRImportPage2(),
            '/ADD/QUIZLET': (context) => const QuizletImportPage(),
            '/SETTINGS': (context) => const SettingsNavigator(),
          },
        ),
      )
    );
  });
}