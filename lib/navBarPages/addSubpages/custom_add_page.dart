import 'dart:math';

import 'package:card_flash/database.dart';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker_plus/flutter_iconpicker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets.dart';
import '../home_page.dart';

import '../../constants.dart';

class CustomAddPage extends StatefulWidget {
  const CustomAddPage({super.key});

  @override
  State<CustomAddPage> createState() => _CustomAddPageState();
}

class _CustomAddPageState extends State<CustomAddPage> {
  final _formKey = GlobalKey<FormState>();
  double? value = 0.0;
  int cardNum = 1;
  Set<int> ignoreList = {};
  IconData? _icon = Icons.quiz_rounded;
  Wrapper? title = Wrapper(null);
  Wrapper? desc = Wrapper(null);
  Wrapper? terms = Wrapper({});
  Wrapper? defs = Wrapper({});
  var termCont = [];
  var defCont = [];

  @override
  initState() {
    super.initState();
    _setUpControllers();
  }

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

  _setUpControllers() {
    for (int i = termCont.length; i < cardNum; i++) {
      termCont.add(TextEditingController());
      defCont.add(TextEditingController());
    }
  }

  void _removeCard(int val) {
    setState(() {
      ignoreList.add(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
            appBar: BetterAppBar(
              "Create a Set", <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                  child: ExpandTapWidget(
                    tapPadding: const EdgeInsets.all(5.0),
                    onTap: () async {
                      value = null;
                      final navigator = Navigator.of(context);
                      List<String> termsList = [], defsList = [];
                      for (int i = 0; i < cardNum; i++) {
                        if (!ignoreList.contains(i)) {
                          termsList.add(terms?.object[i] ?? "");
                          defsList.add(defs?.object[i] ?? "");
                        }
                      }
                      if (_formKey.currentState!.validate()) {
                        // print(LocalDatabase.get)
                        await (await SharedPreferences.getInstance()).setInt("currentTitleID", await LocalDatabase.insertSet(CardSet(await LocalDatabase.getNextPositionSet(), ((title?.object == null) ? "" : title?.object), ((desc?.object == null) ? "" : desc?.object), _icon!, termsList, defsList)));
                        navigator.push(
                            PageRouteBuilder(
                              pageBuilder: (c, a1, a2) => const HomeNavigator(),
                              settings: const RouteSettings(name: "/HOME"),
                              transitionDuration: Duration.zero,
                            )
                        );
                        navigator.pushNamed('/HOME/SET');
                        navigator.pushNamed('/HOME/SET/EDIT');
                      }
                      value = 0.0;
                    },
                    child: Icon(
                      Icons.check_rounded,
                      color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black : Colors.white,
                    ),
                  )
              )
            ], Padding(
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
            ), PreferredSize(
              preferredSize: const Size(double.infinity, 1.0),
              child: LinearProgressIndicator(
                value: value,
                semanticsLabel: "Checks form and then submits it into the database",
              ),
            ),),
            body: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    BetterTextFormField("Enter a title", null, true, "A title is required!", title, null, null),
                    BetterTextFormField("Enter a description (Optional)", null, false, null, desc, null, null),
                    const Padding(padding: EdgeInsets.only(bottom: 5)),
                    Center(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: InkWell(
                          splashColor: MediaQuery.of(context).platformBrightness == Brightness.light ?  Constants.lightModeSplash :  Constants.darkModeSplash,
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
                        newIndex = min(newIndex, cardNum - 1);
                        var tempTerms = Map.from(terms?.object);
                        var tempDefs = Map.from(defs?.object);
                        terms?.object[newIndex] = tempTerms[oldIndex];
                        defs?.object[newIndex] = tempDefs[oldIndex];
                        if (newIndex < oldIndex) {
                          for (int i = newIndex; i < oldIndex; i++) {
                            terms?.object[i + 1] = tempTerms[i];
                            defs?.object[i + 1] = tempDefs[i];
                          }
                        }
                        else if (newIndex > oldIndex) {
                          for (int i = oldIndex + 1; i <= newIndex; i++) {
                            terms?.object[i - 1] = tempTerms[i];
                            defs?.object[i - 1] = tempDefs[i];
                          }
                        }
                        for (int i = 0; i < terms?.object.length; i++) {
                          termCont[i].text = terms?.object[i] ?? '';
                          defCont[i].text = defs?.object[i] ?? '';
                        }
                      },
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int i) {
                        return Slidable(
                          key: Key(i.toString()),
                          endActionPane: ActionPane(
                            extentRatio: 0.25,
                            motion: const DrawerMotion(),
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
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 50),
                      child: ExpandTapWidget(
                        tapPadding: const EdgeInsets.all(5.0),
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
        )
    );
  }
}