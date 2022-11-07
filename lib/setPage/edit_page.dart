import 'package:card_flash/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../navBarPages/home_page.dart';
import '../widgets.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  double? value = 0.0;
  late int cardNum;
  int cardMinus = 0;
  Set<int> ignoreList = {};
  late IconData? _icon;
  late Wrapper title;
  late Wrapper desc;
  Wrapper? terms = Wrapper({});
  Wrapper? defs = Wrapper({});
  var termCont = [];
  var defCont = [];

  _pickIcon() async {
    IconData? icon = await FlutterIconPicker.showIconPicker(context, iconPackModes: [
      IconPack.material,
      IconPack.cupertino,
      IconPack.fontAwesomeIcons,
      IconPack.lineAwesomeIcons,
    ]);

    setState(() {
      _icon = (icon != null) ? icon : _icon;
    });
  }

  void _grabSomeData() async {
    var data = await LocalDatabase.getSet();
    _icon = IconData(data[0]['iconCP'], fontFamily: data[0]['iconFF'] == "" ? null : data[0]['iconFF'], fontPackage: data[0]['iconFP'] == "" ? null : data[0]['iconFP']);
    title = Wrapper(data[0]['title']);
    desc = Wrapper(data[0]['desc']);
    cardNum = data.length - 1;
    _setUpControllers();
    for (int i = 0; i < cardNum; i++) {
      termCont[i].text = data[i + 1]['term'];
      defCont[i].text = data[i + 1]['def'];
    }
  }

  _setUpControllers() {
    for (int i = 0; i < cardNum; i++) {
      termCont.add(TextEditingController());
      defCont.add(TextEditingController());
    }
  }

  @override
  void initState() {
    super.initState();
    _grabSomeData();
  }

  void _removeCard(int val) {
    setState(() {
      ignoreList.add(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: LocalDatabase.getSet(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Scaffold(
                appBar: BetterAppBar("Edit",
                  <Widget>[
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                      child: GestureDetector(
                        onTap: () async {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Are you sure you want to delete this set?', semanticsLabel: "Are you sure you want to delete this set?"),
                              content: const Text('This process is currently irreversible!', semanticsLabel: "This process is currently irreversible!"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel', semanticsLabel: "Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final navigator = Navigator.of(context);
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    navigator.push(
                                        PageRouteBuilder(
                                          pageBuilder: (c, a1, a2) => const HomeNavigator(),
                                          settings: const RouteSettings(name: "/HOME"),
                                          transitionDuration: Duration.zero,
                                        )
                                    );
                                    await Future.delayed(const Duration(milliseconds: 50));
                                    await LocalDatabase.deleteSet((await SharedPreferences.getInstance()).getInt('currentTitleID'));
                                  },
                                  child: const Text(
                                    'Confirm',
                                    semanticsLabel: "Confirm",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Icon(
                          Icons.delete_rounded,
                          color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black : Colors.white,
                        ),
                      )
                  )
                ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                    child: GestureDetector(
                      onTap: () async {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        var termDefChanged = false;
                        if (snapshot.data.length - 1 == cardNum + cardMinus) {
                          for (int i = 0; i < cardNum; i++) {
                            if (!ignoreList.contains(i)) {
                              if ((terms?.object[i] != null) && (terms?.object[i] != snapshot.data[i + 1]['term']) || ((defs?.object[i] != null) && (defs?.object[i] != snapshot.data[i + 1]['def']))) {
                                termDefChanged = true;
                                break;
                              }
                            }
                          }
                        }
                        if (termDefChanged || (snapshot.data.length - 1 != cardNum + cardMinus) || ((title.object != null) && (title.object != snapshot.data[0]['title'])) || ((desc.object != null) && (desc.object != snapshot.data[0]['desc'])) || ((_icon?.codePoint != snapshot.data[0]['iconCP']) && (_icon?.fontPackage != snapshot.data[0]['iconFP']) && (_icon?.fontFamily != snapshot.data[0]['iconFF']))) {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Are you sure you want to exit?', semanticsLabel: "Are you sure you want to exit?"),
                              content: const Text('This set has not been saved yet!', semanticsLabel: "This set has not been saved yet!",),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel', semanticsLabel: "Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.popUntil(context, (route) => route.settings.name == "/HOME/SET");
                                  },
                                  child: const Text(
                                    'Exit',
                                    semanticsLabel: "Exit",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        else {
                          Navigator.popUntil(context, (route) => route.settings.name == "/HOME/SET");
                        }
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
                      semanticsLabel: "Checks form and then submits it into the database",
                    ),
                  ),
                ),
                body: DismissKeyboard(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                          children: [
                            BetterTextFormField("Enter a title", null, true, "A title is required", title, title.object, null),
                            BetterTextFormField("Enter a description (Optional)", null, false, null, desc, desc.object, null),
                            const Padding(padding: EdgeInsets.only(bottom: 5)),
                            Center(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: InkWell(
                                  splashColor: Colors.blue.withAlpha(30),
                                  onTap: () {_pickIcon();},
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.95,
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(_icon),
                                          title: Text(
                                            "Pick an icon",
                                            semanticsLabel: "Pick an icon",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).size.height * 0.024,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(bottom: 10)),
                            ReorderableListView.builder(
                              onReorder: (int oldIndex, int newIndex) {
                                newIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
                                var tempTerms = Map.from(terms?.object);
                                var tempDefs = Map.from(defs?.object);
                                terms?.object[newIndex] = tempTerms[oldIndex] ?? snapshot.data[oldIndex + 1]['term'];
                                defs?.object[newIndex] = tempDefs[oldIndex] ?? snapshot.data[oldIndex + 1]['def'];
                                if (newIndex < oldIndex) {
                                  for (int i = newIndex; i < oldIndex; i++) {
                                    terms?.object[i + 1] = tempTerms[i] ?? snapshot.data[i + 1]['term'];
                                    defs?.object[i + 1] = tempDefs[i] ?? snapshot.data[i + 1]['def'];
                                  }
                                }
                                else if (newIndex > oldIndex) {
                                  for (int i = oldIndex + 1; i <= newIndex; i++) {
                                    terms?.object[i - 1] = tempTerms[i] ?? snapshot.data[i + 1]['term'];
                                    defs?.object[i - 1] = tempDefs[i] ?? snapshot.data[i + 1]['def'];
                                  }
                                }
                                for (int i = 0; i < terms?.object.length; i++) {
                                  termCont[i].text = terms?.object[i] ?? snapshot.data[i + 1]['term'];
                                  defCont[i].text = defs?.object[i] ?? snapshot.data[i + 1]['def'];
                                }
                              },
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int i) {
                                return Slidable(
                                  key: Key(i.toString()),
                                  endActionPane: ActionPane(
                                    extentRatio: 0.25,
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          _removeCard(i);
                                        },
                                        backgroundColor: const Color(0xFFFE4A49),
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete_rounded,
                                        label: 'Delete',
                                      ),
                                    ],
                                  ),
                                  child: Padding(padding: const EdgeInsets.only(bottom: 5), child: BetterCardTextForm("Enter a term", "Enter a definition", i, terms, defs, !ignoreList.contains(i), null, null, termCont[i], defCont[i]),),
                                );
                              },
                              itemCount: cardNum,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                              child: GestureDetector(
                                onTap: () {
                                  setState (() {
                                    cardNum++;
                                    _setUpControllers();
                                  });
                                },
                                child: const Icon(
                                  Icons.add_circle_rounded,
                                  size: 30,
                                ),
                              ),
                            ),
                          ]
                      ),
                    )
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    var mess = ScaffoldMessenger.of(context);
                    value = null;
                    List<String> termsList = [], defsList = [];
                    for (int i = 0; i < cardNum; i++) {
                      if (!ignoreList.contains(i)) {
                        termsList.add(terms?.object[i] ?? (snapshot.data.length - 1 > i ? snapshot.data[i+1]['term'] : ""));
                        defsList.add(defs?.object[i] ?? (snapshot.data.length - 1 > i ? snapshot.data[i+1]['def'] : ""));
                      }
                    }
                    if (_formKey.currentState!.validate()) {
                      await LocalDatabase.updateSet(CardSet(snapshot.data[0]['position'], title.object, desc.object, _icon!, termsList, defsList));
                      await LocalDatabase.resetAdaptive();
                      mess.showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.black87,
                          content: Text(
                            'Saved!',
                            semanticsLabel: "Saved!",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          duration: Duration(milliseconds: 1000),
                        ),
                      );
                    }
                    value = 0.0;
                  },
                  backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.green[400] : Colors.green[700],
                  child: const Icon(Icons.check_rounded),
                ),
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