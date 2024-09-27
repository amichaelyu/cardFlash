import 'package:card_flash/setPage/modes/adaptive_page_settings.dart';
import 'package:card_flash/setPage/modes/qr_page.dart';
import 'package:card_flash/setPage/set_page.dart';
import 'package:card_flash/splash_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'constants.dart';
import 'navBarPages/addSubpages/qr_import_page.dart';
import 'navBarPages/addSubpages/custom_add_page.dart';
import 'navBarPages/addSubpages/quizlet_import_page.dart';
import 'navBarPages/addSubpages/text_cardflash_import_page.dart';
import 'navBarPages/settings_page.dart';
import 'setPage/edit_page.dart';
import 'setPage/modes/adaptive_page.dart';
import 'setPage/modes/flashcard_page.dart';
import 'navBarPages/add_page.dart';
import 'navBarPages/home_page.dart';

void main() async {
  // THIS MUST REMAIN AT THE TOP
  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  Constants.setConstants(packageInfo.appName,  packageInfo.version, packageInfo.buildNumber);

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  print(await deviceInfo.deviceInfo);

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
          /*
           ThemeMode.system to follow system theme,
           ThemeMode.light for light theme,
           ThemeMode.dark for dark theme
          */
          initialRoute: '/',
          // onGenerateRoute: (RouteSettings settings) {
          //   switch (settings.name) {
          //     case '/': return CupertinoPageRoute(builder: (_)  => const SplashPage(), settings: settings);
          //     case '/HOME': return CupertinoPageRoute(builder: (_) => HomeNavigator(), settings: settings);
          //     case '/HOME/FOLDER': return CupertinoPageRoute (builder: (_) => const FolderNavigator(), settings: settings);
          //     case '/HOME/SET': return CupertinoPageRoute (builder: (_) => const SetPage(), settings: settings);
          //     case '/HOME/SET/FLASHCARDS': return CupertinoPageRoute(builder: (_) => const FlashcardPage(), settings: settings);
          //     case '/HOME/SET/ADAPTIVE': return CupertinoPageRoute (builder: (_) => const AdaptivePage(), settings: settings);
          //     case '/HOME/SET/ADAPTIVE/SETTINGS': return CupertinoPageRoute(builder: (_) => const AdaptiveSettingsPage(), settings: settings);
          //     case '/HOME/SET/EDIT': return CupertinoPageRoute(builder: (_) => const EditPage(), settings: settings);
          //     case '/HOME/SET/QR': return CupertinoPageRoute (builder: (_) => const QRPage(), settings: settings);
          //     case '/ADD': return CupertinoPageRoute (builder: (_) => const AddNavigator(), settings: settings);
          //     case '/ADD/CUSTOM': return CupertinoPageRoute(builder: (_) => const CustomAddPage(), settings: settings);
          //     case '/ADD/QR': return CupertinoPageRoute (builder: (_) => const QRImportPage(), settings: settings);
          //     case '/ADD/INTERSUB': return CupertinoPageRoute(builder: (_) => const InterSubPage(), settings: settings);
          //     case '/ADD/QUIZLET': return CupertinoPageRoute(builder: (_) => const QuizletImportPage(), settings: settings);
          //     case '/SETTINGS': return CupertinoPageRoute(builder: (_) => const SettingsNavigator(), settings: settings);
          //   }
          // },
          routes: {
            '/': (context) => const SplashPage(),
            '/HOME': (context) => const HomeNavigator(),
            '/HOME/FOLDER': (context) => const FolderPage(),
            '/HOME/SET': (context) => const SetPage(),
            '/HOME/SET/FLASHCARDS': (context) => const FlashcardPage(),
            '/HOME/SET/ADAPTIVE': (context) => const AdaptivePage(),
            '/HOME/SET/ADAPTIVE/SETTINGS': (context) => const AdaptiveSettingsPage(),
            '/HOME/SET/EDIT': (context) => const EditPage(),
            '/HOME/SET/QR': (context) => const QRPage(),
            '/ADD': (context) => const AddNavigator(),
            '/ADD/TEXT_CARDFLASH': (context) => const CardFlashImportPage(),
            '/ADD/CUSTOM': (context) => const CustomAddPage(),
            '/ADD/QR': (context) => const QRImportPage(),
            // '/ADD/INTERSUB': (context) => const InterSubPage(),
            '/ADD/QUIZLET': (context) => const QuizletImportPage(),
            '/SETTINGS': (context) => const SettingsNavigator(),
          },
        ),
      )
    );
  });
}