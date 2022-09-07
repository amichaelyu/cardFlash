import 'package:card_flash/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
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
  Set<int> ignoreList = {};
  late IconData? _icon;
  Object? title = Object(null);
  Object? desc = Object(null);
  Object? terms = Object({});
  Object? defs = Object({});

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
    var data = await Database.getSetFuture();
    _icon = IconData(data[0]['iconCP'], fontFamily: data[0]['iconFF'], fontPackage: data[0]['iconFP']);
    cardNum = data.length - 1;
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
    return StreamBuilder(
        stream: Database.getSetStream(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  leading: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: GestureDetector(
                        onTap: () async {
                          value = null;
                          final navigator = Navigator.of(context);
                          List<String> termsList = [], defsList = [];
                          for (int i = 0; i < cardNum; i++) {
                            if (!ignoreList.contains(i)) {
                              termsList.add(terms?.object[i] ?? (snapshot.data.length - 1 <= cardNum ? snapshot.data[i+1]['term'] : ""));
                              defsList.add(defs?.object[i] ?? (snapshot.data.length - 1 <= cardNum ? snapshot.data[i+1]['def'] : ""));
                            }
                          }
                          if (_formKey.currentState!.validate()) {
                            await Database.updateSet(CardSet(snapshot.data[0]['position'], ((title?.object == null) ? snapshot.data[0]['title'] : title?.object), ((desc?.object == null) ? snapshot.data[0]['desc'] : desc?.object), _icon!, termsList, defsList));
                            navigator.pop();
                          }
                          value = 0.0;
                        },
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                        ),
                      )
                  ),
                  backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.white : null,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.white : Colors.black,
                    statusBarIconBrightness: MediaQuery.of(context).platformBrightness == Brightness.light ? Brightness.dark : Brightness.light, // android
                    statusBarBrightness: MediaQuery.of(context).platformBrightness == Brightness.light ? Brightness.light : Brightness.dark, // ios
                  ),
                  titleTextStyle: TextStyle(
                    color: MediaQuery.of(context).platformBrightness != Brightness.light ? Colors.white : Colors.black,
                    fontSize: 30,
                  ),
                  iconTheme: IconThemeData(color: MediaQuery.of(context).platformBrightness != Brightness.light ? Colors.white : Colors.black),
                  title: const Text(
                    "Edit",
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  actions: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                        child: GestureDetector(
                          onTap: () async {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Are you sure you want to delete this set?'),
                                content: const Text('This process is currently irreversible!'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.popUntil(context, (route) => route.settings.name == "/HOME");
                                      await Future.delayed(const Duration(seconds: 1));
                                      await Database.deleteSet();
                                    },
                                    child: const Text(
                                        'Confirm',
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
                  bottom: PreferredSize(
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
                            BetterTextFormField("Enter a title", null, true, "A title is required", title, snapshot.data[0]['title']),
                            BetterTextFormField("Enter a description (Optional)", null, false, null, desc, snapshot.data[0]['desc']),
                            const Padding(padding: EdgeInsets.only(bottom: 5)),
                            Center(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: InkWell(
                                  splashColor: Colors.blue.withAlpha(30),
                                  onTap: () {_pickIcon();},
                                  child: SizedBox(
                                    width: 370,
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(_icon),
                                          title: const Text(
                                            "Choose an icon",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          // subtitle: Text(desc),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(bottom: 10)),
                            for (int i = 0; i < cardNum; i++)
                              Slidable(
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
                                child: Padding(padding: const EdgeInsets.only(bottom: 5), child: BetterCardTextForm("Enter a term", "Enter a definition", i, terms, defs, !ignoreList.contains(i), snapshot.data.length - 1 >= cardNum ? snapshot.data[i+1]['term'] : null, snapshot.data.length - 1 >= cardNum ? snapshot.data[i+1]['def'] : null),),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: GestureDetector(
                                onTap: () {
                                  setState (() {
                                    cardNum++;
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
          else if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
            return const Text('');
          }
          else {
            return Scaffold(
                appBar: BetterAppBar(Constants.title, null, Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                      ),
                    )
                ),
                ),
                body: ListView(children: const [
                  Padding(padding: EdgeInsets.only(top: 20),
                    child: Align(alignment: Alignment.center,
                      child: Text("Something went wrong :(",
                        style: TextStyle(fontSize: 20,),),),)
                ])
            );
          }
    }
    );
  }
}