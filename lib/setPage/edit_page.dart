import 'package:card_flash/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int cardNum = 0;
  int cardMinus = 0;
  Set<int> ignoreList = {};
  IconData? _icon = const IconData(0);
  TextEditingController title = TextEditingController();
  TextEditingController desc = TextEditingController();
  Wrapper? terms = Wrapper({});
  Wrapper? defs = Wrapper({});
  var termCont = [];
  var defCont = [];
  late dynamic snapshot;

  @override
  void initState() {
    super.initState();
    _grabSomeData();
  }

  _pickIcon() async {
    IconData? icon =
    await FlutterIconPicker.showIconPicker(context, iconPackModes: [
      IconPack.material,
      IconPack.cupertino,
      IconPack.fontAwesomeIcons,
      IconPack.lineAwesomeIcons,
    ]);

    _icon = (icon != null) ? icon : _icon;
    setState(() {});
  }

  Future<dynamic> _grabSomeData() async {
    value = null;
    setState(() {});
    snapshot = await LocalDatabase.getSet();
    _icon = IconData(snapshot[0]['iconCP'],
        fontFamily: snapshot[0]['iconFF'] == "" ? null : snapshot[0]['iconFF'],
        fontPackage: snapshot[0]['iconFP'] == "" ? null : snapshot[0]['iconFP']);
    title.text = snapshot[0]['title'];
    desc.text = snapshot[0]['desc'];
    cardNum = snapshot.length - 1;
    _setUpControllers();
    for (int i = 0; i < cardNum; i++) {
      termCont[i].text = snapshot[i + 1]['term'];
      defCont[i].text = snapshot[i + 1]['def'];
    }
    value = 0;
    setState(() {});
    return snapshot;
  }

  _setUpControllers() {
    for (int i = 0; i < cardNum; i++) {
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
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Scaffold(
                  appBar: BetterAppBar(
                    "Edit",
                    <Widget>[
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                          child: GestureDetector(
                            onTap: () async {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) =>
                                    AlertDialog(
                                      title: const Text(
                                          'Are you sure you want to delete this set?',
                                          semanticsLabel:
                                          "Are you sure you want to delete this set?"),
                                      content: const Text(
                                          'This process is currently irreversible!',
                                          semanticsLabel:
                                          "This process is currently irreversible!"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel',
                                              semanticsLabel: "Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final navigator = Navigator.of(
                                                context);
                                            ScaffoldMessenger.of(context)
                                                .clearSnackBars();
                                            await LocalDatabase.deleteSet(
                                                (await SharedPreferences
                                                    .getInstance())
                                                    .getInt('currentTitleID'));
                                            navigator.push(PageRouteBuilder(
                                              pageBuilder: (c, a1, a2) =>
                                              const HomeNavigator(),
                                              settings: const RouteSettings(
                                                  name: "/HOME"),
                                              transitionDuration: Duration.zero,
                                            ));
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
                              color:
                              MediaQuery
                                  .of(context)
                                  .platformBrightness ==
                                  Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ))
                    ],
                    Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                        child: GestureDetector(
                          onTap: () async {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            var data = await LocalDatabase.getSet();
                            var termDefChanged = false;
                            if (data.length - 1 ==
                                cardNum + cardMinus) {
                              for (int i = 0; i < cardNum; i++) {
                                if (!ignoreList.contains(i)) {
                                  if ((terms?.object[i] != null) &&
                                      (terms?.object[i] !=
                                          data[i + 1]['term']) ||
                                      ((defs?.object[i] != null) &&
                                          (defs?.object[i] !=
                                              data[i + 1]['def']))) {
                                    termDefChanged = true;
                                    break;
                                  }
                                }
                              }
                            }
                            if (termDefChanged ||
                                (data.length - 1 !=
                                    cardNum + cardMinus) ||
                                ((title.text != "") &&
                                    (title.text !=
                                        data[0]['title'])) ||
                                ((desc.text != "") &&
                                    (desc.text !=
                                        data[0]['desc'])) ||
                                ((_icon?.codePoint !=
                                    data[0]['iconCP']) &&
                                    (_icon?.fontPackage !=
                                        data[0]['iconFP']) &&
                                    (_icon?.fontFamily !=
                                        data[0]['iconFF']))) {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) =>
                                    AlertDialog(
                                      title: const Text(
                                          'Are you sure you want to exit?',
                                          semanticsLabel:
                                          "Are you sure you want to exit?"),
                                      content: const Text(
                                        'This set has not been saved yet!',
                                        semanticsLabel:
                                        "This set has not been saved yet!",
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel',
                                              semanticsLabel: "Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.popUntil(
                                                context,
                                                    (route) =>
                                                route.settings.name ==
                                                    "/HOME/SET");
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
                            } else {
                              Navigator.popUntil(
                                  context,
                                      (route) =>
                                  route.settings.name == "/HOME/SET");
                            }
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                          ),
                        )),
                    PreferredSize(
                      preferredSize: const Size(double.infinity, 1.0),
                      child: LinearProgressIndicator(
                        value: value,
                        semanticsLabel:
                        "Checks form and then submits it into the database",
                      ),
                    ),
                  ),
                  body: Form(
                    key: _formKey,
                    child: CustomScrollView(slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          addAutomaticKeepAlives: true,
                          (context, index) => [
                            BetterTextFormField(
                                "Enter a title",
                                null,
                                true,
                                "A title is required",
                                null,
                                null,
                                title),
                            BetterTextFormField(
                                "Enter a description (Optional)",
                                null,
                                false,
                                null,
                                null,
                                null,
                                desc),
                            const Padding(padding: EdgeInsets.only(bottom: 5)),
                            Center(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: InkWell(
                                  splashColor: Colors.blue.withAlpha(30),
                                  onTap: () {
                                    _pickIcon();
                                  },
                                  child: SizedBox(
                                    width:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.95,
                                    child: ListTile(
                                      leading: Icon(_icon),
                                      title: Text(
                                        "Pick an icon",
                                        semanticsLabel: "Pick an icon",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .height *
                                              0.024,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(bottom: 10)),
                          ][index],
                          childCount: 5,
                        ),
                      ),
                      SliverReorderableList(
                        onReorder: (int oldIndex, int newIndex) {
                          newIndex =
                          newIndex > oldIndex ? newIndex - 1 : newIndex;
                          var tempTerms = Map.from(terms?.object);
                          var tempDefs = Map.from(defs?.object);
                          terms?.object[newIndex] = tempTerms[oldIndex] ??
                              snapshot[oldIndex + 1]['term'];
                          defs?.object[newIndex] = tempDefs[oldIndex] ??
                              snapshot[oldIndex + 1]['def'];
                          if (newIndex < oldIndex) {
                            for (int i = newIndex; i < oldIndex; i++) {
                              terms?.object[i + 1] = tempTerms[i] ??
                                  snapshot[i + 1]['term'];
                              defs?.object[i + 1] = tempDefs[i] ??
                                  snapshot[i + 1]['def'];
                            }
                          } else if (newIndex > oldIndex) {
                            for (int i = oldIndex + 1; i <=
                                newIndex; i++) {
                              terms?.object[i - 1] = tempTerms[i] ??
                                  snapshot[i + 1]['term'];
                              defs?.object[i - 1] = tempDefs[i] ??
                                  snapshot[i + 1]['def'];
                            }
                          }
                          for (int i = 0; i < terms?.object.length; i++) {
                            termCont[i].text = terms?.object[i] ??
                                snapshot[i + 1]['term'];
                            defCont[i].text = defs?.object[i] ??
                                snapshot[i + 1]['def'];
                          }
                        },
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
                                  backgroundColor: const Color(
                                      0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_rounded,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: BetterCardTextForm(
                                  "Enter a term",
                                  "Enter a definition",
                                  i,
                                  terms,
                                  defs,
                                  !ignoreList.contains(i),
                                  null,
                                  null,
                                  termCont[i],
                                  defCont[i]),
                            ),
                          );
                        },
                        itemCount: cardNum,
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 50),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      cardNum++;
                                      _setUpControllers();
                                    });
                                  },
                                  child: const Icon(
                                    Icons.add_circle_rounded,
                                    size: 35,
                                  ),
                                ),
                              ),
                            ][index],
                          childCount: 1,
                        ),
                      ),
                    ]
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () async {
                      var mess = ScaffoldMessenger.of(context);
                      var data = await LocalDatabase.getSet();
                      value = null;
                      List<String> termsList = [],
                          defsList = [];
                      for (int i = 0; i < cardNum; i++) {
                        if (!ignoreList.contains(i)) {
                          termsList.add(terms?.object[i] ??
                              (data.length - 1 > i
                                  ? data[i + 1]['term']
                                  : ""));
                          defsList.add(defs?.object[i] ??
                              (data.length - 1 > i
                                  ? data[i + 1]['def']
                                  : ""));
                        }
                      }
                      if (_formKey.currentState!.validate()) {
                        await LocalDatabase.updateSet(CardSet(
                            data[0]['position'],
                            title.text,
                            desc.text,
                            _icon!,
                            termsList,
                            defsList));
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
                    backgroundColor:
                    MediaQuery
                        .of(context)
                        .platformBrightness ==
                        Brightness.light
                        ? Colors.green[400]
                        : Colors.green[700],
                    child: const Icon(Icons.check_rounded),
                  ),
                ));
  }
}