import 'package:card_flash/better_scroll_physics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../database.dart';
import '../../widgets.dart';

enum Menu { shuffle, termFront, reset }

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  int _index = 0;
  var controller = PageController(viewportFraction: 0.825);
  late bool shuffle;
  late List<String> text = [];
  var shuffleList = [];
  late List<String> termDef;
  late int colorLight;
  late int colorDark;
  late bool haptics;

  _loadDB() async {
    var set = await LocalDatabase.getSet();
    shuffle = set[0]['flashcardShuffle'] == 1;
    termDef = set[0]['flashcardTermDef'] == 0 ? ['term', 'def'] : ['def', 'term'];
  }

  _loadTerms() async {
    var set = await LocalDatabase.getSet();
    text.clear();
    shuffleList.clear();
    for (int i = 1; i < set.length; i++) {
      shuffleList.add(i);
    }
    if (!shuffle) {
      for (int i = 1; i < set.length; i++) {
        text.add(set[i][termDef[0]]);
      }
    }
    else {
      shuffleList.shuffle();
      for (int i = 0; i < set.length - 1; i++) {
        text.add(set[shuffleList[i]][termDef[0]]);
      }
    }

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
    _loadDB();
    _loadTerms();
    _loadPrefs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: LocalDatabase.getSet(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Scaffold(
                appBar: BetterAppBar("Flashcards", <Widget>[
                  PopupMenuButton<Menu>(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      size: 30,
                      ),
                    onSelected: (Menu item) {
                      switch (item) {
                        case Menu.shuffle:
                          shuffle = !shuffle;
                          _loadTerms();
                          LocalDatabase.updateFlashcardShuffle(shuffle ? 1 : 0);
                          break;
                        case Menu.termFront:
                          var temp = termDef[1];
                          termDef[1] = termDef[0];
                          termDef[0] = temp;
                          _loadTerms();
                          LocalDatabase.updateFlashcardTermDef(termDef[0] == 'term' ? 0 : 1);
                          break;
                        case Menu.reset:
                          controller.animateToPage(0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                          _loadTerms();
                          break;
                      }
                      setState(() {});
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                      PopupMenuItem<Menu>(
                        value: Menu.shuffle,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Shuffle ', semanticsLabel: "Shuffle",),
                            shuffle ? const Icon(Icons.check_rounded) : const Text(''),
                          ],
                        ),
                      ),
                      PopupMenuItem<Menu>(
                        value: Menu.termFront,
                        child: termDef[0] == 'term' ? const Text('Term Front', semanticsLabel: 'Term Front',) : const Text('Def Front', semanticsLabel: "Def Front",),
                      ),
                      const PopupMenuItem<Menu>(
                        value: Menu.reset,
                        child: Text('Reset', semanticsLabel: 'Reset',),
                      ),
                    ]),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                    ),
                  )
                ), null),
                body: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.77, // card height
                      child: PageView.builder(
                        physics: const BetterBouncingScrollPhysics(),
                        itemCount: snapshot.data.length - 1,
                        controller: controller,
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
                              child: InkWell(
                                splashColor: Colors.blue.withAlpha(30),
                                onTap: () {
                                  text[i] = (text[i] == snapshot.data[shuffleList[i]][termDef[0]]) ? snapshot.data[shuffleList[i]][termDef[1]] : snapshot.data[shuffleList[i]][termDef[0]];
                                  if (haptics) HapticFeedback.mediumImpact();
                                  setState(() {});
                                },
                                child: SizedBox(
                                  child: Center(
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: [
                                          Padding(
                                            padding: const EdgeInsets
                                                .all(10),
                                            child: Text(
                                              text[i],
                                              semanticsLabel: text[i],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context).size.height * 0.036),
                                            ),
                                          )
                                        ],
                                      ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
            );
          }
          else if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
            return Scaffold(
                appBar: BetterAppBar("Flashcards", null, Padding(
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
                body: const Text('', semanticsLabel: '',));
          }
          else {
            return Scaffold(
                appBar: BetterAppBar("Flashcards", null, Padding(
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
                body: Column(children:  [
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