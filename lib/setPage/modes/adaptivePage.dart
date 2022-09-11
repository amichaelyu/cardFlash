import 'dart:math';

import 'package:flutter/material.dart';
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
  var shuffledList = [];
  late int colorLight;
  late int colorDark;
  int counter = 0;
  var answers = [];
  var colorList = [];
  late String prompt = '';
  late String answer = '';
  var showAnswer = false;
  var writingVal = Object(null);
  late num mcNum;
  late num writingNum;
  late var maintainMC;
  late var maintainW;
  late var valueSetter;
  final writingController = TextEditingController();

  _initializeCardColor() async {
    colorLight = (await SharedPreferences.getInstance()).getInt("cardColorLight")!;
    colorDark = (await SharedPreferences.getInstance()).getInt("cardColorDark")!;
  }

  _initialAsync() async {
    var set = await Database.getSet();
    mcNum = set[0]['multipleChoiceQuestions'] * (set[0]['multipleChoiceEnabled'] == 1 ? (set[0]['adaptiveTermDef'] > 0 ? 1 : 2) : 0);
    writingNum = set[0]['writingQuestions'] * (set[0]['writingEnabled'] == 1 ? (set[0]['adaptiveTermDef'] > 0 ? 1 : 2) : 0);
    for (int i = 1; i < set.length; i++) {
      valueCounter += set[i]['correctInARowTerm'];
      valueCounter += set[i]['correctInARowDef'];
      if ((set[i]['correctInARowTerm'] + set[i]['correctInARowDef']) < (mcNum + writingNum)) {
        shuffledList.add(i);
      }
    }
    shuffledList.shuffle();
    totalVal = (set.length - 1) * (mcNum + writingNum);
    value = valueCounter / totalVal;
    maintainMC = false;
    maintainW = false;
  }

  _generateSet(int pos) async {
    var set = await Database.getSet();
    answers.clear();
    colorList.clear();
    if (shuffledList.isNotEmpty) {
      switch (set[0]['adaptiveTermDef']) {
        case 0:
          if (set[shuffledList[pos]]['correctInARowTerm'] >
              set[shuffledList[pos]]['correctInARowDef']) {
            prompt = set[shuffledList[pos]]['def'];
            answer = set[shuffledList[pos]]['term'];
            answers.add(answer);
            while (answers.length != min<num>(4, (set.length - 1))) {
              var word = set[(Random().nextInt(set.length - 1)) + 1]['term'];
              if (!answers.contains(word)) {
                answers.add(word);
              }
            }
            answers.shuffle();
            answers.add(1);
          }
          else {
            prompt = set[shuffledList[pos]]['term'];
            answer = set[shuffledList[pos]]['def'];
            answers.add(answer);
            while (answers.length != min<num>(4, (set.length - 1))) {
              var word = set[(Random().nextInt(set.length - 1)) + 1]['def'];
              if (!answers.contains(word)) {
                answers.add(word);
              }
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
            var word = set[(Random().nextInt(set.length - 1)) + 1]['term'];
            if (!answers.contains(word)) {
              answers.add(word);
            }
          }
          answers.shuffle();
          answers.add(1);
          break;
        case 2:
          prompt = set[shuffledList[pos]]['term'];
          answer = set[shuffledList[pos]]['def'];
          answers.add(answer);
          while (answers.length != min<num>(4, (set.length - 1))) {
            var word = set[(Random().nextInt(set.length - 1)) + 1]['def'];
            if (!answers.contains(word)) {
              answers.add(word);
            }
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
  }

  _updateCounter(int valueUpdate) async {
    var set = await Database.getSet();
    if (counter < (shuffledList.length - 2)) {
      counter++;
    }
    else {
      counter = 0;
      shuffledList.clear();
      for (int i = 1; i < set.length; i++) {
        if ((set[i]['correctInARowTerm'] + set[i]['correctInARowDef']) < (mcNum + writingNum)) {
          shuffledList.add(i);
        }
      }
      shuffledList.shuffle();
    }
    _generateSet(counter);
    writingVal = Object(null);
    valueCounter += valueUpdate;
    value = valueCounter / totalVal;
  }

  @override
  void initState() {
    super.initState();
    _initializeCardColor();
    _initialAsync();
    _generateSet(0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Database.getSet(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Scaffold(
                appBar: BetterAppBar(
                  "Adaptive", <Widget>[
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: GestureDetector(
                        onTap: () {
                          nav() async {
                            await Navigator.pushNamed(context, "/HOME/SET/ADAPTIVE/SETTINGS");
                            _initializeCardColor();
                            _initialAsync();
                            _generateSet(0);
                          }
                          setState(() {
                            nav();
                          });
                        },
                        child: const Icon(
                          Icons.settings_rounded,
                          size: 25,
                        ),
                      )
                  )]
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
                    ),
                  PreferredSize(
                    preferredSize: const Size(double.infinity, 1.0),
                    child: LinearProgressIndicator(
                      value: value.isNaN ? 0 : value,
                      semanticsLabel: "Indicates learn progress",
                    ),
                  ),),
                body: ListView(
                    children: [
                      //  prompt
                      if (shuffledList.isNotEmpty)
                        Padding(
                                padding: const EdgeInsets
                                .fromLTRB(10, 20, 10, 20),
                          child: Text(
                          prompt,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.036),
                          ),
                        ),
                      // multiple choice
                      if (shuffledList.isNotEmpty && ((snapshot.data[shuffledList[counter]]['correctInARowTerm'] + snapshot.data[shuffledList[counter]]['correctInARowDef']) < mcNum || maintainMC) && !maintainW)
                        for (int i = 0; i < min<num>(4, (snapshot.data.length-1)); i++)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.95,
                              child: Transform.scale(
                                scale: 0.98,
                                child: Card(
                                  elevation: 6,
                                  color: !showAnswer ? (MediaQuery
                                      .of(context)
                                      .platformBrightness ==
                                      Brightness.light
                                      ? Color(colorLight)
                                      : Color(colorDark)) : colorList[i],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          15)),
                                  child: InkWell(
                                    onTap: () async {
                                      var mess = ScaffoldMessenger.of(context);
                                      if (showAnswer != true) {
                                        maintainMC = true;
                                        if (colorList[i] != Colors.green) {
                                          var db = await Database.getSet();
                                          valueSetter = -1 * db[shuffledList[counter]][answers.last == 1 ? 'correctInARowDef' : 'correctInARowTerm'];
                                          colorList[i] = Colors.red;
                                          Database.updateCorrectIncorrect(shuffledList[counter]-1, -1);
                                          Database.resetCorrectInARow(shuffledList[counter]-1, answers.last);
                                          mess.showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.black87,
                                              content: Text(
                                                'Incorrect! Click any answer to move on!',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              duration: Duration(milliseconds: 5000),
                                            ),
                                          );
                                        }
                                        else {
                                          valueSetter = 1;
                                          Database.increaseCorrectInARow(shuffledList[counter] - 1, answers.last);
                                          Database.updateCorrectIncorrect(shuffledList[counter] - 1, 1);
                                          mess.showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.black87,
                                              content: Text(
                                                'Correct! Click any answer to move on!',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              duration: Duration(milliseconds: 3000),
                                            ),
                                          );
                                        }
                                        showAnswer = true;
                                      }
                                      else {
                                        maintainMC = false;
                                        showAnswer = false;
                                        mess.hideCurrentSnackBar();
                                        _updateCounter(valueSetter);
                                      }
                                    },
                                    splashColor: Colors.blue.withAlpha(30),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets
                                            .fromLTRB(10, 25, 10, 25),
                                        child: Text(
                                          answers.elementAt(i),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context).size.height * 0.036),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      // writing thing
                      if (shuffledList.isNotEmpty && (((snapshot.data[shuffledList[counter]]['correctInARowTerm'] + snapshot.data[shuffledList[counter]]['correctInARowDef']) >= mcNum && (snapshot.data[shuffledList[counter]]['correctInARowTerm'] + snapshot.data[shuffledList[counter]]['correctInARowDef']) < writingNum + mcNum) || maintainW) && !maintainMC)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: DismissKeyboard(
                            child: BetterTextFormField(
                              "Write the answer",
                              showAnswer ? answer : null,
                              false,
                              null,
                              writingVal,
                              null,
                              writingController
                            ),
                          ),
                        ),
                      // finished
                      if (shuffledList.isEmpty)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                             Padding(padding: const EdgeInsets.only(top: 225),
                              child: Text("You learned everything!",
                                style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.036,),),),
                          Padding(padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(MediaQuery.of(context).platformBrightness == Brightness.light ? Color(colorLight) : Color(colorDark)),
                              ),
                              onPressed: () {
                                Database.resetAdaptive();
                                _initialAsync();
                                _generateSet(0);
                                valueCounter = 0;
                              },
                              child: Text("Restart",
                                style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.024,),),)
                          )
                          ]
                        ),
                    ]
                  ),
                floatingActionButton: (shuffledList.isNotEmpty && (((snapshot.data[shuffledList[counter]]['correctInARowTerm'] + snapshot.data[shuffledList[counter]]['correctInARowDef']) >= mcNum && (snapshot.data[shuffledList[counter]]['correctInARowTerm'] + snapshot.data[shuffledList[counter]]['correctInARowDef']) < writingNum + mcNum) || maintainW) && !maintainMC) ? FloatingActionButton(
                  onPressed: () async {
                    var mess = ScaffoldMessenger.of(context);
                    if (showAnswer != true) {
                      maintainW = true;
                      maintainMC = false;
                      if (writingVal.object != answer) {
                        writingController.clear();
                        var set = await Database.getSet();
                        var incorrect = set[shuffledList[counter]-1]['incorrectTotal'];
                        var correctInARow = answers.last == 1 ? set[shuffledList[counter]]['correctInARowDef'] : set[shuffledList[counter]]['correctInARowTerm'];
                        valueSetter = -1 * correctInARow;
                        await Database.updateCorrectIncorrect(shuffledList[counter]-1, -1);
                        await Database.resetCorrectInARow(shuffledList[counter]-1, answers.last);
                        mess.showSnackBar(
                          SnackBar(
                            action: SnackBarAction(
                              label: 'Override',
                              onPressed: () async {
                                await Database.setCorrectInARow(shuffledList[counter]-1, correctInARow + 1, answers.last);
                                await Database.setCorrectIncorrect(shuffledList[counter]-1, -incorrect);
                                await Database.updateCorrectIncorrect(shuffledList[counter]-1, 1);
                                maintainW = false;
                                showAnswer = false;
                                writingController.clear();
                                mess.hideCurrentSnackBar();
                                _updateCounter(1);
                              },
                            ),
                            backgroundColor: Colors.black87,
                            content: const Text(
                              'Incorrect! Type the correct answer to move on!',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            duration: const Duration(milliseconds: 5000),
                          ),
                        );
                      }
                      else {
                        valueSetter = 1;
                        Database.increaseCorrectInARow(shuffledList[counter] - 1, answers.last);
                        Database.updateCorrectIncorrect(shuffledList[counter]-1, 1);
                        mess.showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.black87,
                            content: Text(
                              'Correct! Click the button again to move on!',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            duration: Duration(milliseconds: 3000),
                          ),
                        );
                      }
                      showAnswer = true;
                    }
                    else if (writingVal.object == answer) {
                      maintainW = false;
                      showAnswer = false;
                      // if (writing)
                      writingController.clear();
                      mess.hideCurrentSnackBar();
                      _updateCounter(valueSetter);
                    }
                  },
                  backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.green[400] : Colors.green[700],
                  child: const Icon(Icons.check_rounded),
                ) : null,
            );
          }
          else if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
            return const Text('');
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
                body: ListView(children: [
                  Padding(padding: const EdgeInsets.only(top: 20),
                    child: Align(alignment: Alignment.center,
                      child: Text("Something went wrong :(",
                        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.024,),),),)
                ])
            );
          }
        }
    );
  }
}