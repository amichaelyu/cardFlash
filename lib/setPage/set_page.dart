import 'package:auto_size_text/auto_size_text.dart';
import 'package:card_flash/better_scroll_physics.dart';
import 'package:card_flash/constants.dart';
import 'package:card_flash/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database.dart';

class SetPage extends StatefulWidget {
  const SetPage({super.key});

  @override
  State<SetPage> createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  int _index = 0;
  late int colorLight;
  late int colorDark;
  late bool haptics;
  var controller = PageController(viewportFraction: 0.8);

  nav() async {
    await Navigator.pushNamed(context, "/HOME/SET/EDIT");
    setState(() {
      controller.animateToPage(0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    });
  }

  _loadPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    colorLight = prefs.getInt("cardColorLight")!;
    colorDark = prefs.getInt("cardColorDark")!;
    haptics = prefs.getBool("haptics")!;
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: LocalDatabase.getSet(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Scaffold(
                appBar: BetterAppBar(snapshot.data.first['title'],
                    <Widget>[
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                          child: GestureDetector(
                            onTap: () {
                              nav();
                              ScaffoldMessenger.of(context).clearSnackBars();
                            },
                            child: Icon(
                              Icons.edit_rounded,
                              color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black : Colors.white,
                            ),
                          )
                      )
                    ]
                    , Padding(
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
                body: ListView(
                    children: [
                      Padding(
                        padding: snapshot.data.first['desc'] == ""
                            ? EdgeInsets.zero
                            : const EdgeInsets.fromLTRB(10, 0, 10, 15),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(snapshot.data.first['desc'],
                            semanticsLabel: snapshot.data.first['desc'],
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.028,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.47, // card height
                          child: PageView.builder(
                            itemCount: snapshot.data.length - 1,
                            controller: controller,
                            physics: const BetterBouncingScrollPhysics(),
                            onPageChanged: (int index) => setState(() {
                              _index = index;
                              if (haptics) HapticFeedback.selectionClick();
                            }),
                            itemBuilder: (_, i) {
                              return Transform.scale(
                                scale: i == _index ? 1 : 0.9,
                                child: Card(
                                  elevation: 6,
                                  color: MediaQuery
                                      .of(context)
                                      .platformBrightness ==
                                      Brightness.light
                                      ? Color(colorLight)
                                      : Color(colorDark),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20)),
                                  child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(
                                              15),
                                          child: AutoSizeText(
                                            snapshot.data[i + 1]['term'],
                                            semanticsLabel: snapshot.data[i+1]['term'],
                                            maxLines: 7,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.height * 0.034),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets
                                              .fromLTRB(10, 0, 10, 0),
                                          child: AutoSizeText(
                                            snapshot.data[i + 1]['def'],
                                            semanticsLabel: snapshot.data[i+1]['def'],
                                            maxLines: 13,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.height * 0.026),
                                          ),
                                        ),
                                      ]
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const BetterCardSet(
                          "Flashcards", Icons.style_rounded, "/HOME/SET/FLASHCARDS"),
                      const BetterCardSet(
                          "Adaptive", Icons.memory_rounded, "/HOME/SET/ADAPTIVE"),
                      const BetterCardSet(
                          "QR", Icons.qr_code_2_rounded, "/HOME/SET/QR"),
                    ]
                )
            );
          }
          else if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
            return const Text('', semanticsLabel: '');
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
              ),
              null),
              body: ListView(children: [
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