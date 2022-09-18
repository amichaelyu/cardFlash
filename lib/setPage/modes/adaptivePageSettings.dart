import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../database.dart';
import '../../widgets.dart';

class AdaptiveSettingsPage extends StatefulWidget {
  const AdaptiveSettingsPage({super.key});

  @override
  State<AdaptiveSettingsPage> createState() => _AdaptiveSettingsPageState();
}

class _AdaptiveSettingsPageState extends State<AdaptiveSettingsPage> {
  var value = 0.0;
  late var dropdownPosition;
  late var multipleChoiceEnabled;
  late var writingEnabled;
  late var multipleChoiceQuestions;
  late var writingQuestions;
  late var repeatQuestions;

  _readDB() async {
    var db = await Database.getSet();
    dropdownPosition = db[0]['adaptiveTermDef'];
    multipleChoiceEnabled = db[0]['multipleChoiceEnabled'] == 1;
    writingEnabled = db[0]['writingEnabled'] == 1;
    multipleChoiceQuestions = Object(db[0]['multipleChoiceQuestions'].toString());
    writingQuestions = Object(db[0]['writingQuestions'].toString());
    repeatQuestions = Object(db[0]['adaptiveRepeat'].toString());
  }

  @override
  void initState() {
    super.initState();
    _readDB();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Database.getSet(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Scaffold(
                appBar: BetterAppBar("Adaptive Settings", null, Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                        child: GestureDetector(
                          onTap: () async {
                            final navigator = Navigator.of(context);
                            await Database.updateAdaptiveSettings(dropdownPosition, multipleChoiceEnabled ? 1 : 0, writingEnabled ? 1 : 0, int.parse(multipleChoiceQuestions.object), int.parse(writingQuestions.object), repeatQuestions);
                            navigator.pop();
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                          ),
                        )
                    ),
                  PreferredSize(
                    preferredSize: const Size(double.infinity, 1.0),
                    child: LinearProgressIndicator(
                      value: value,
                      semanticsLabel: "Indicates loading while communicating with database",
                    ),
                  ),),
                body: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
                        child: Column(
                              children: [
                                const Text("What to study?", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 20),
                                    child: DropdownButton(value: ["Terms & Definitions", "Terms", "Definitions"][dropdownPosition], items: ["Terms & Definitions", "Terms", "Definitions"].map<DropdownMenuItem<String>>((String value) {return DropdownMenuItem<String>(value: value,child: Text(value),);}).toList(), onChanged: (value) { setState(() {
                                      switch (value) {
                                        case "Terms & Definitions":
                                          dropdownPosition = 0;
                                          break;
                                        case "Terms":
                                          dropdownPosition = 1;
                                          break;
                                        case "Definitions":
                                          dropdownPosition = 2;
                                          break;
                                        default:
                                          break;
                                      }
                                    });
                                }, isExpanded: true, style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.02, color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black : Colors.white),),),
                        ]),
                      ),
                      Center(
                      child: Card(
                        color: multipleChoiceEnabled ? Colors.green : Colors.red,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {
                          multipleChoiceEnabled = !multipleChoiceEnabled;
                          setState(() {});
                        },
                        child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.77,
                        height: MediaQuery.of(context).size.height * 0.071,
                        child: Padding(padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.020, 0, 0), child: Text("Multiple Choice ${multipleChoiceEnabled ? "Enabled" : "Disabled"}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                        ),
                        ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      Center(
                        child: Card(
                          color: writingEnabled ? Colors.green : Colors.red,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: InkWell(
                            splashColor: Colors.blue.withAlpha(30),
                            onTap: () {
                              writingEnabled = !writingEnabled;
                              setState(() {});
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.77,
                              height: MediaQuery.of(context).size.height * 0.071,
                              child: Padding(padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.020, 0, 0), child: Text("Writing ${writingEnabled ? "Enabled" : "Disabled"}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 15),
                      ),
                      BetterTextFormFieldNumbersOnly("Number of multiple choice questions", null, null, null, multipleChoiceQuestions, multipleChoiceQuestions.object, null),
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      BetterTextFormFieldNumbersOnly("Number of writing questions", null, null, null, writingQuestions, writingQuestions.object, null),
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      BetterTextFormFieldNumbersOnly("Number of questions per group", "Each question will stay in the group until you master it", null, null, repeatQuestions, repeatQuestions.object, null),
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      BetterCardSettings("Reset Adaptive Mode",
                              () { showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                        title: const Text('Are you sure you want to reset?'),
                        content: const Text('This will reset all of your current progress!'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Database.resetAdaptive();
                            },
                            child: const Text(
                              'Confirm',
                              style: TextStyle(color: Colors.red),
                          ),
                          ),
                          ],
                          ),
                        );}, null),
                    ]
                )
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