import 'package:card_flash/better_scroll_physics.dart';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database.dart';
import '../../widgets.dart';

enum Menu { enhanced , shuffle, termFront, reset }

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  int _index = 0;
  late bool _isAdaptive = false;
  var controller = PageController(viewportFraction: 0.825);
  late bool shuffle;
  late List<List<String>> text = [];
  late List<List<String>> textSaved = [];
  var shuffleList = [];
  late List<String> termDef;
  late final int colorLight;
  late final int colorDark;
  late final int colorLighter;
  late final int colorDarker;
  late bool haptics;

  _switchBetterFlashcard() async {
    _isAdaptive = !_isAdaptive;
    _index = 0;
    await LocalDatabase.updateFlashcardAdaptive(_isAdaptive ? 1 : 0);
  }

  _resetLearned() async {
    await LocalDatabase.resetFlashcardAdaptiveLearned();
    _loadTerms();
    controller.animateToPage(
        0, duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn);
    _index = 0;
  }

  _learned() async {
    if (haptics) HapticFeedback.mediumImpact();
    await LocalDatabase.updateFlashcardAdaptiveLearned(int.parse(text[_index][1]), 1);
    if (_index == text.length - 1) {
      _loadTerms();
      controller.animateToPage(
          0, duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn);
      _index = 0;
    }
    else {
      controller.animateToPage(
          _index + 1, duration: const Duration(milliseconds: 250),
          curve: Curves.easeIn);
    }
  }

  _notLearned() async {
    if (haptics) HapticFeedback.mediumImpact();
    await LocalDatabase.updateFlashcardAdaptiveLearned(int.parse(text[_index][1]), 0);
    if (_index == text.length - 1) {
      _loadTerms();
      controller.animateToPage(
          0, duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn);
      _index = 0;
    }
    else {
      controller.animateToPage(
          _index + 1, duration: const Duration(milliseconds: 250),
          curve: Curves.easeIn);
    }
  }

  _loadDB() async {
    var set = await LocalDatabase.getSet();
    shuffle = set[0]['flashcardShuffle'] == 1;
    termDef = set[0]['flashcardTermDef'] == 0 ? ['term', 'def'] : ['def', 'term'];
    _isAdaptive = set[0]['flashcardAdaptive'] == 1;
    _loadTerms();
  }

  _loadTerms() async {
    var set = _isAdaptive ? await LocalDatabase.getNotLearnedFlashcardAdaptive() : await LocalDatabase.getSet();
    text.clear();
    shuffleList.clear();
    textSaved.clear();
    for (int i = 1; i < set.length; i++) {
        shuffleList.add(i);
      }
    if (shuffle) {
      shuffleList.shuffle();
    }
    for (int i = 0; i < shuffleList.length; i++) {
      List<String> row = [];
      textSaved.add([set[shuffleList[i]][termDef[0]], set[shuffleList[i]][termDef[1]]]);
      row.add(set[shuffleList[i]][termDef[0]]);
      row.add(set[shuffleList[i]]['cardID'].toString());
      text.add(row);
    }
    setState(() {});
  }

  _loadPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    colorLight = prefs.getInt("cardColorLight")!;
    colorDark = prefs.getInt("cardColorDark")!;
    colorLighter = prefs.getInt("cardColorLighter")!;
    colorDarker = prefs.getInt("cardColorDarker")!;
    haptics = prefs.getBool("haptics")!;
  }

  @override
  void initState() {
    super.initState();
    _loadDB();
    _loadPrefs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
                appBar: BetterAppBar("Flashcards", <Widget>[
                  PopupMenuButton<Menu>(
                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 30,
                        color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black : Colors.white,
                      ),
                      onSelected: (Menu item) {
                        switch (item) {
                          case Menu.enhanced:
                            _switchBetterFlashcard();
                            break;
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
                            _resetLearned();
                            break;
                        }
                        setState(() {});
                      },
                      itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<Menu>>[
                        PopupMenuItem<Menu>(
                          value: Menu.enhanced,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _isAdaptive ?
                              Padding(
                                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02),
                                  child: const Icon(Icons.check_rounded)
                              ) : Padding(
                                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.06),
                              ),
                              const Text(
                                'Enhanced ', semanticsLabel: "Enhanced",),
                            ],
                          ),
                        ),
                        PopupMenuItem<Menu>(
                          value: Menu.shuffle,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              shuffle ?
                              Padding(
                                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02),
                                  child: const Icon(Icons.check_rounded)
                              ) : Padding(
                                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.06),
                              ),
                              const Text(
                                'Shuffle ', semanticsLabel: "Shuffle",),
                            ],
                          ),
                        ),
                        PopupMenuItem<Menu>(
                          value: Menu.termFront,
                          child: termDef[0] == 'term'
                              ? const Text(
                            'Term Front', semanticsLabel: 'Term Front',)
                              : const Text(
                            'Def Front', semanticsLabel: "Def Front",),
                        ),
                        const PopupMenuItem<Menu>(
                          value: Menu.reset,
                          child: Text('Reset', semanticsLabel: 'Reset',),
                        ),
                      ]),
                ],
                    Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                        child: ExpandTapWidget(
                        tapPadding: const EdgeInsets.all(5.0),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                          ),
                        )
                    ), null),
                body: !_isAdaptive ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                  child: SizedBox(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.77, // card height
                    child: PageView.builder(
                      physics: const BetterBouncingScrollPhysics(),
                      itemCount: text.length,
                      controller: controller,
                      onPageChanged: (int index) =>
                          setState(() {
                            _index = index;
                            if (haptics) HapticFeedback.mediumImpact();
                          }),
                      itemBuilder: (_, i) {
                        return Transform.scale(
                                scale: i == _index ? 1 : 0.9,
                                child: StatefulBuilder(
                                    builder: (context, setState) {
                                      return Card(
                                  elevation: 6,
                                  color: text[i][0] == textSaved[i][0] ? MediaQuery
                                      .of(context)
                                      .platformBrightness ==
                                      Brightness.light
                                      ? Color(colorLight)
                                      : Color(colorDarker) : MediaQuery
                                      .of(context)
                                      .platformBrightness ==
                                      Brightness.light
                                      ? Color(colorLighter)
                                      : Color(colorDark),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20)),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () {
                                      text[i][0] = text[i][0] == textSaved[i][0] ? textSaved[i][1] : textSaved[i][0];
                                      if (haptics) HapticFeedback.heavyImpact();
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
                                          text[i][0],
                                          semanticsLabel: text[i][0],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height * 0.036),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );}),
                        );
                      },
                    ),
                  ),
                ) : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                  child: Column(children:
                  [
                    if (text.isNotEmpty)
                      Column(children:
                      [
                        SizedBox(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.7, // card height
                        child: PageView.builder(
                          physics: const BetterBouncingScrollPhysics(),
                          itemCount: text.length,
                          controller: controller,
                          onPageChanged: (int index) =>
                              setState(() {
                                _index = index;
                                if (haptics) HapticFeedback.mediumImpact();
                              }),
                          itemBuilder: (_, i) {
                            return Transform.scale(
                              scale: i == _index ? 1 : 0.9,
                              child: StatefulBuilder(
                                  builder: (context, setState) {
                                    return Card(
                                      elevation: 6,
                                      color: text[i][0] == textSaved[i][0] ? MediaQuery
                                          .of(context)
                                          .platformBrightness ==
                                          Brightness.light
                                          ? Color(colorLight)
                                          : Color(colorDarker) : MediaQuery
                                          .of(context)
                                          .platformBrightness ==
                                          Brightness.light
                                          ? Color(colorLighter)
                                          : Color(colorDark),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20)),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        splashColor: Colors.blue.withAlpha(30),
                                        onTap: () {
                                          text[i][0] = text[i][0] == textSaved[i][0] ? textSaved[i][1] : textSaved[i][0];
                                          if (haptics) HapticFeedback.heavyImpact();
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
                                                    text[i][0],
                                                    semanticsLabel: text[i][0],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .height * 0.036),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );}),
                            );
                          },
                        ),
                      ),
                        Padding(padding: EdgeInsets.only(top: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02)),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BetterCardInstant(
                              "Don't Know", _notLearned, MediaQuery
                              .of(context)
                              .platformBrightness == Brightness.light ? Colors
                              .grey.shade400 : Colors.grey.shade800),
                          BetterCardInstant("Learned", _learned, MediaQuery
                              .of(context)
                              .platformBrightness == Brightness.light ? Colors
                              .green[400] : Colors.green[700]),
                        ],
                      ),
                      ]
                      ),
                    if (text.isEmpty)
                      Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 225),
                            child: Text(
                              "You learned everything!",
                              semanticsLabel: "You learned everything!",
                              style: TextStyle(
                                fontSize:
                                MediaQuery.of(context).size.height *
                                    0.036,
                              ),
                            ),
                          ),
                          Padding(
                              padding:
                              const EdgeInsets.fromLTRB(40, 20, 40, 0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(
                                      MediaQuery.of(context)
                                          .platformBrightness ==
                                          Brightness.light
                                          ? Color(colorLight)
                                          : Color(colorDark)),
                                ),
                                onPressed: () {
                                  if (haptics) HapticFeedback.heavyImpact();
                                  LocalDatabase.resetAdaptive();
                                  _resetLearned();
                                  setState(() {});
                                },
                                child: Text(
                                  "Restart",
                                  semanticsLabel: "Restart",
                                  style: TextStyle(
                                    fontSize:
                                    MediaQuery.of(context).size.height *
                                        0.024,
                                  ),
                                ),
                              ))
                        ]),),
                  ]),
                ),
        );
  }
}