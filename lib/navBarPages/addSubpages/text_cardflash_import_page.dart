import 'package:card_flash/database.dart';
import 'package:dio/dio.dart';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/material.dart';
import 'package:lzstring/lzstring.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../widgets.dart';
import '../home_page.dart';

class CardFlashImportPage extends StatefulWidget {

  const CardFlashImportPage({super.key});

  @override
  State<CardFlashImportPage> createState() => CardFlashImportPageState();
  }

class CardFlashImportPageState extends State<CardFlashImportPage> {
  final link = Wrapper(null);
  String data = "";
  bool running = false;
  double? value = 0.0;

  @override
  void initState() {
    super.initState();
    data = "";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: BetterAppBar(
            "cardFlash Import", null, Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
              child: ExpandTapWidget(
                tapPadding: const EdgeInsets.all(5.0),
                onTap: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
              )
          ), PreferredSize(
              preferredSize: const Size(double.infinity, 1.0),
              child: LinearProgressIndicator(
                value: value,
                semanticsLabel: "Checks form and then submits it into the database",
              ),
            ),),
          body: Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: ListView(
                  children: [
                    BetterTextFormField("Enter your cardFlash code", null, null, null, link, null, null),
                  ]
              )
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (!running) {
                running = true;
                value = null;
                setState(() {});
                final navigator = Navigator.of(context);
                var mess = ScaffoldMessenger.of(context);
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                final terms = <String>[];
                final defs = <String>[];

                mess.clearSnackBars();
                mess.showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.black87,
                    content: Text(
                      "Processing...",
                      semanticsLabel: "Processing...",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    duration: Duration(milliseconds: 5000),
                  ),
                );

                var id = link.object;
                var dio = Dio();
                try {
                  var response = await dio.get(
                    "https://api.paste.ee/v1/pastes/${id!}",
                    queryParameters: {
                      'key': Constants.pasteAPIKey,
                    },
                  );
                  if (response.data['success']) {
                    data = response.data['paste']["sections"][0]["contents"];
                    final uncompressed = LZString.decompressFromUTF16Sync(data);
                    final list = uncompressed?.split("§¶");
                    if (list?.last == "") {
                      list?.removeLast();
                    }
                    for (int i = 5; i < list!.length; i += 2) {
                      terms.add(list[i]);
                      defs.add(list[i + 1]);
                    }
                    await prefs.setInt("currentTitleID",
                        await LocalDatabase.insertSet(CardSet(
                            await LocalDatabase.getNextPositionSet(), list[0],
                            list[1], IconData(
                            int.parse(list[2]), fontFamily: list[3],
                            fontPackage: list[4] == "null" ? null : list[4]),
                            terms, defs))
                    );
                    navigator.push(
                        PageRouteBuilder(
                          pageBuilder: (c, a1, a2) => const HomeNavigator(),
                          settings: const RouteSettings(name: "/HOME"),
                          transitionDuration: Duration.zero,
                        )
                    );
                    navigator.pushNamed('/HOME/SET');
                    navigator.pushNamed('/HOME/SET/EDIT');
                    mess.clearSnackBars();
                  }
                  else {
                    mess.clearSnackBars();
                    mess.showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.black87,
                        content: Text(
                          'That set can\'t be found! Try refreshing the code!',
                          semanticsLabel: 'That set can\'t be found! Try refreshing the code!',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        duration: Duration(milliseconds: 5000),
                      ),
                    );
                  }
                } catch (e) {
                  mess.clearSnackBars();
                  mess.showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.black87,
                      content: Text(
                        'That set can\'t be found! Try refreshing the code!',
                        semanticsLabel: 'That set can\'t be found! Try refreshing the code!',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      duration: Duration(milliseconds: 5000),
                    ),
                  );
                }
                running = false;
                value = 0.0;
                dio.close();
                setState(() {});
              }
            },
            backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.green[400] : Colors.green[700],
            child: const Icon(Icons.check_rounded),
          ),
        ));
  }
}