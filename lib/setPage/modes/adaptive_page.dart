import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../database.dart';
import '../../widgets.dart';

class AdaptivePage extends StatefulWidget {
  const AdaptivePage({super.key});

  @override
  State<AdaptivePage> createState() => _AdaptivePageState();
}

class _AdaptivePageState extends State<AdaptivePage> {
  var value = 0.0;
  var valueCounter = 0.0;
  late int totalVal;
  var shuffledList = []; // contains the positions of the initial list
  late int colorLight;
  late int colorDark;
  late bool haptics;
  int counter = 0;
  var answers = [];
  var colorList = [];
  late String prompt = '';
  late String answer = '';
  var showAnswer = false;
  var writingVal = Wrapper(null);
  late num mcNum;
  late num writingNum;
  late bool maintainMC;
  late bool maintainW;
  late num valueSetter;
  late int repeatNum;
  int nullCounter = 0;
  final writingController = TextEditingController();

  _loadPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    colorLight = prefs.getInt("cardColorLight")!;
    colorDark = prefs.getInt("cardColorDark")!;
    haptics = prefs.getBool("haptics")!;
  }

  _initialAsync() async {
    showAnswer = false;
    var set = await LocalDatabase.getSet();
    writingController.clear();
    mcNum = set[0]['multipleChoiceQuestions'] *
        (set[0]['multipleChoiceEnabled'] == 1
            ? (set[0]['adaptiveTermDef'] > 0 ? 1 : 2)
            : 0);
    writingNum = set[0]['writingQuestions'] *
        (set[0]['writingEnabled'] == 1
            ? (set[0]['adaptiveTermDef'] > 0 ? 1 : 2)
            : 0);
    shuffledList.clear();
    valueCounter = 0;
    repeatNum = set[0]['adaptiveRepeat'];
    for (int i = 1; i < set.length; i++) {
      valueCounter += set[i]['correctInARowTerm'];
      valueCounter += set[i]['correctInARowDef'];
      if ((set[i]['correctInARowTerm'] + set[i]['correctInARowDef']) <
          (mcNum + writingNum)) {
        shuffledList.add(i);
      }
    }
    shuffledList.shuffle();
    shuffledList.removeRange(
        min(repeatNum, shuffledList.length), shuffledList.length);
    totalVal = (set.length - 1) * (mcNum + writingNum);
    value = valueCounter / totalVal;
    maintainMC = false;
    maintainW = false;
  }

  _generateSet(int pos) async {
    var set = await LocalDatabase.getSet();
    int number;
    Set<int> nums = {};
    answers.clear();
    colorList.clear();
    if (shuffledList.isNotEmpty) {
      switch (set[0]['adaptiveTermDef']) {
        case 0:
          bool flip = set[shuffledList[pos]]['correctInARowTerm'] >
                  set[shuffledList[pos]]['correctInARowDef']
              ? true
              : (set[shuffledList[pos]]['correctInARowTerm'] ==
                      set[shuffledList[pos]]['correctInARowDef'])
                  ? Random().nextBool()
                  : false;
          if (flip) {
            prompt = set[shuffledList[pos]]['def'];
            answer = set[shuffledList[pos]]['term'];
            answers.add(answer);
            while (answers.length != min<num>(4, (set.length - 1))) {
              number = (Random().nextInt(set.length - 1)) + 1;
              var word = set[number]['term'];
              if (!answers.contains(word) || nums.length == (set.length - 1)) {
                answers.add(word);
              }
              nums.add(number);
            }
            answers.shuffle();
            answers.add(1);
          } else {
            prompt = set[shuffledList[pos]]['term'];
            answer = set[shuffledList[pos]]['def'];
            answers.add(answer);
            while (answers.length != min<num>(4, (set.length - 1))) {
              number = (Random().nextInt(set.length - 1)) + 1;
              var word = set[number]['def'];
              if (!answers.contains(word) || nums.length == (set.length - 1)) {
                answers.add(word);
              }
              nums.add(number);
            }
            answers.shuffle();
            answers.add(2);
          }
          break;
        case 1:
          prompt = set[shuffledList[pos]]['def'];
          answer = set[shuffledList[pos]]['term'];
          answers.add(answer);
          while (answers.length != min<num>(4, (set.length - 1))) {
            number = (Random().nextInt(set.length - 1)) + 1;
            var word = set[number]['term'];
            if (!answers.contains(word) || nums.length == (set.length - 1)) {
              answers.add(word);
            }
            nums.add(number);
          }
          answers.shuffle();
          answers.add(1);
          break;
        case 2:
          prompt = set[shuffledList[pos]]['term'];
          answer = set[shuffledList[pos]]['def'];
          answers.add(answer);
          while (answers.length != min<num>(4, (set.length - 1))) {
            number = (Random().nextInt(set.length - 1)) + 1;
            var word = set[number]['def'];
            if (!answers.contains(word) || nums.length == (set.length - 1)) {
              answers.add(word);
            }
            nums.add(number);
          }
          answers.shuffle();
          answers.add(2);
          break;
        default:
          break;
      }
    }
    for (var i in answers) {
      colorList.add((i == answer ? Colors.green : null));
    }
    setState(() {});
  }

  _updateCounter(int valueUpdate) async {
    var set = await LocalDatabase.getSet();
    if (counter == (shuffledList.length - 1)) {
      var randomList = [];
      for (int i = 1; i < set.length; i++) {
        if ((set[i]['correctInARowTerm'] + set[i]['correctInARowDef']) <
            (mcNum + writingNum)) {
          randomList.add(i);
        }
      }
      randomList.shuffle();
      int len = min(min(shuffledList.length, randomList.length), repeatNum);
      for (int i = 0; i < shuffledList.length; i++) {
        if ((set[shuffledList[i]]['correctInARowTerm'] +
                set[shuffledList[i]]['correctInARowDef']) >=
            mcNum) {
          shuffledList.removeAt(i);
          i--;
        }
      }
      for (int i = shuffledList.length; i < len; i++) {
        if (!shuffledList.contains(randomList[i]))
          shuffledList.add(randomList[i]);
      }
      shuffledList.shuffle();
      counter = 0;
    } else if (counter < (shuffledList.length - 1)) {
      counter++;
    }
    _generateSet(counter);
    writingVal = Wrapper(null);
    valueCounter += valueUpdate;
    value = valueCounter / totalVal;
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _initialAsync();
    _generateSet(0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: FutureBuilder(
            future: LocalDatabase.getSet(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.data != null) {
                return Scaffold(
                  appBar: BetterAppBar(
                    "Adaptive",
                    <Widget>[
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: GestureDetector(
                            onTap: () async {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              await Navigator.pushNamed(
                                  context, "/HOME/SET/ADAPTIVE/SETTINGS");
                              _loadPrefs();
                              _initialAsync();
                              _generateSet(0);
                              setState(() {});
                            },
                            child: const Icon(
                              Icons.settings_rounded,
                              size: 25,
                            ),
                          ))
                    ],
                    Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                          ),
                        )),
                    PreferredSize(
                      preferredSize: const Size(double.infinity, 1.0),
                      child: LinearProgressIndicator(
                        value: value.isNaN || value.isInfinite ? 0 : value,
                        semanticsLabel: "Indicates learn progress",
                      ),
                    ),
                  ),
                  body: Center(
                    child: Column(children: [
                      //  prompt
                      if (shuffledList.isNotEmpty)
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: MediaQuery.of(context).size.height * 0.28,
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 20, 10, 20),
                              child: AutoSizeText(
                                prompt,
                                semanticsLabel: prompt,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.04),
                              ),
                            ),
                          ),
                        ),
                      // multiple choice
                      if (shuffledList.isNotEmpty &&
                          ((snapshot.data[shuffledList[counter]]
                                          ['correctInARowTerm'] +
                                      snapshot.data[shuffledList[counter]]
                                          ['correctInARowDef']) <
                                  mcNum ||
                              maintainMC) &&
                          !maintainW)
                        for (int i = 0;
                            i < min<num>(4, (snapshot.data.length - 1));
                            i++)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.95,
                              height: MediaQuery.of(context).size.height * 0.13,
                              child: Transform.scale(
                                scale: 0.98,
                                child: Card(
                                  elevation: 6,
                                  color: !showAnswer
                                      ? (MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.light
                                          ? Color(colorLight)
                                          : Color(colorDark))
                                      : colorList[i],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  child: InkWell(
                                    onTap: () async {
                                      var mess = ScaffoldMessenger.of(context);
                                      if (showAnswer != true) {
                                        maintainMC = true;
                                        if (colorList[i] != Colors.green) {
                                          if (haptics)
                                            HapticFeedback.heavyImpact();
                                          var db = await LocalDatabase.getSet();
                                          valueSetter = -1 *
                                              db[shuffledList[counter]][
                                                  answers.last == 1
                                                      ? 'correctInARowDef'
                                                      : 'correctInARowTerm'];
                                          colorList[i] = Colors.red;
                                          LocalDatabase.updateCorrectIncorrect(
                                              shuffledList[counter] - 1, -1);
                                          LocalDatabase.resetCorrectInARow(
                                              shuffledList[counter] - 1,
                                              answers.last);
                                          mess.showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.black87,
                                              content: Text(
                                                'Incorrect! Click any answer to move on!',
                                                semanticsLabel:
                                                    "Incorrect! Click any answer to move on!",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              duration:
                                                  Duration(milliseconds: 10000),
                                            ),
                                          );
                                        } else {
                                          if (haptics)
                                            HapticFeedback.lightImpact();
                                          valueSetter = 1;
                                          LocalDatabase.increaseCorrectInARow(
                                              shuffledList[counter] - 1,
                                              answers.last);
                                          LocalDatabase.updateCorrectIncorrect(
                                              shuffledList[counter] - 1, 1);
                                          mess.showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.black87,
                                              content: Text(
                                                'Correct! Click any answer to move on!',
                                                semanticsLabel:
                                                    "Correct! Click any answer to move on!",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              duration:
                                                  Duration(milliseconds: 3000),
                                            ),
                                          );
                                        }
                                        showAnswer = true;
                                        if ((await SharedPreferences
                                                    .getInstance())
                                                .getBool("adaptiveInstant")! &&
                                            valueSetter > 0) {
                                          maintainMC = false;
                                          showAnswer = false;
                                          mess.clearSnackBars();
                                          _updateCounter(valueSetter.toInt());
                                        }
                                      } else {
                                        if (haptics)
                                          HapticFeedback.mediumImpact();
                                        maintainMC = false;
                                        showAnswer = false;
                                        mess.clearSnackBars();
                                        _updateCounter(valueSetter.toInt());
                                      }
                                      setState(() {});
                                    },
                                    splashColor: Colors.blue.withAlpha(30),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 5, 15, 5),
                                        child: AutoSizeText(
                                          answers.elementAt(i),
                                          maxLines: 10,
                                          minFontSize: 10,
                                          semanticsLabel: answers.elementAt(i),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.028),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      // writing thing
                      if (shuffledList.isNotEmpty &&
                          (((snapshot.data[shuffledList[counter]]
                                              ['correctInARowTerm'] +
                                          snapshot.data[shuffledList[counter]]
                                              ['correctInARowDef']) >=
                                      mcNum &&
                                  (snapshot.data[shuffledList[counter]]
                                              ['correctInARowTerm'] +
                                          snapshot.data[shuffledList[counter]]
                                              ['correctInARowDef']) <
                                      writingNum + mcNum) ||
                              maintainW) &&
                          !maintainMC)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: BetterTextFormField(
                              showAnswer ? answer : "Write the answer",
                              null,
                              false,
                              null,
                              writingVal,
                              null,
                              writingController,
                              big: showAnswer),
                        ),
                      // finished
                      if (shuffledList.isEmpty)
                        Column(
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
                                      LocalDatabase.resetAdaptive();
                                      _initialAsync();
                                      _generateSet(0);
                                      valueCounter = 0;
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
                            ]),
                    ]),
                  ),
                  floatingActionButton: (shuffledList.isNotEmpty &&
                          (((snapshot.data[shuffledList[counter]]
                                              ['correctInARowTerm'] +
                                          snapshot.data[shuffledList[counter]]
                                              ['correctInARowDef']) >=
                                      mcNum &&
                                  (snapshot.data[shuffledList[counter]]
                                              ['correctInARowTerm'] +
                                          snapshot.data[shuffledList[counter]]
                                              ['correctInARowDef']) <
                                      writingNum + mcNum) ||
                              maintainW) &&
                          !maintainMC)
                      ? FloatingActionButton(
                          onPressed: () async {
                            var mess = ScaffoldMessenger.of(context);
                            if ((writingVal.object == null ||
                                    writingVal.object.trim() == "") &&
                                nullCounter == 0) {
                              if (haptics) HapticFeedback.lightImpact();
                              nullCounter++;
                              mess.showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.black87,
                                  content: Text(
                                    'Don\'t Know? Click the button again to see the answer!',
                                    semanticsLabel: "",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  duration: Duration(milliseconds: 5000),
                                ),
                              );
                            } else if (showAnswer != true) {
                              mess.clearSnackBars();
                              var correct = (writingVal.object ?? "")
                                      .toLowerCase()
                                      .trim() ==
                                  answer.toLowerCase().trim();
                              maintainW = true;
                              maintainMC = false;
                              if (nullCounter != 0 || !correct) {
                                if (haptics) HapticFeedback.heavyImpact();
                                writingController.clear();
                                var set = await LocalDatabase.getSet();
                                int incorrect = set[shuffledList[counter]]
                                    ['incorrectTotal'];
                                var correctInARow = answers.last == 1
                                    ? set[shuffledList[counter]]
                                        ['correctInARowDef']
                                    : set[shuffledList[counter]]
                                        ['correctInARowTerm'];
                                valueSetter = -1 * correctInARow;
                                await LocalDatabase.updateCorrectIncorrect(
                                    shuffledList[counter] - 1, -1);
                                await LocalDatabase.resetCorrectInARow(
                                    shuffledList[counter] - 1, answers.last);
                                mess.showSnackBar(
                                  SnackBar(
                                    action: SnackBarAction(
                                      label: 'Override',
                                      onPressed: () async {
                                        if (haptics)
                                          HapticFeedback.heavyImpact();
                                        await LocalDatabase.setCorrectInARow(
                                            shuffledList[counter] - 1,
                                            correctInARow + 1,
                                            answers.last);
                                        await LocalDatabase.setCorrectIncorrect(
                                            shuffledList[counter] - 1,
                                            -1 * incorrect);
                                        await LocalDatabase
                                            .updateCorrectIncorrect(
                                                shuffledList[counter] - 1, 1);
                                        maintainW = false;
                                        showAnswer = false;
                                        writingController.clear();
                                        mess.clearSnackBars();
                                        _updateCounter(1);
                                        setState(() {});
                                      },
                                    ),
                                    backgroundColor: Colors.black87,
                                    content: const Text(
                                      'Incorrect! Click the button again to move on!',
                                      semanticsLabel: "Incorrect",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    duration:
                                        const Duration(milliseconds: 5000),
                                  ),
                                );
                              } else {
                                if (haptics) HapticFeedback.lightImpact();
                                valueSetter = 1;
                                LocalDatabase.increaseCorrectInARow(
                                    shuffledList[counter] - 1, answers.last);
                                LocalDatabase.updateCorrectIncorrect(
                                    shuffledList[counter] - 1, 1);
                                mess.showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.black87,
                                    content: Text(
                                      'Correct! Click the button again to move on!',
                                      semanticsLabel:
                                          "Correct! Click the button again to move on!",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 3000),
                                  ),
                                );
                              }
                              showAnswer = true;
                              if (nullCounter == 0 &&
                                  (await SharedPreferences.getInstance())
                                      .getBool("adaptiveInstant")! &&
                                  correct) {
                                nullCounter = 0;
                                maintainW = false;
                                showAnswer = false;
                                writingController.clear();
                                mess.clearSnackBars();
                                _updateCounter(valueSetter.toInt());
                              }
                            } else {
                              if (haptics) HapticFeedback.lightImpact();
                              nullCounter = 0;
                              maintainW = false;
                              showAnswer = false;
                              writingController.clear();
                              mess.clearSnackBars();
                              _updateCounter(valueSetter.toInt());
                            }
                            setState(() {});
                          },
                          backgroundColor:
                              MediaQuery.of(context).platformBrightness ==
                                      Brightness.light
                                  ? Colors.green[400]
                                  : Colors.green[700],
                          child: const Icon(Icons.check_rounded),
                        )
                      : null,
                );
              } else if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.connectionState == ConnectionState.none) {
                return Scaffold(
                    appBar: BetterAppBar(
                        "Adaptive",
                        null,
                        Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                              ),
                            )),
                        null),
                    body: const Text('', semanticsLabel: ''));
              } else {
                return Scaffold(
                    appBar: BetterAppBar(
                        "Adaptive",
                        null,
                        Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                              ),
                            )),
                        null),
                    body: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Something went wrong :(",
                            semanticsLabel: "Something went wrong",
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.024,
                            ),
                          ),
                        ),
                      )
                    ]));
              }
            }));
  }
}