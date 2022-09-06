import 'dart:collection';

import 'package:card_flash/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets.dart';

class CustomAddPage extends StatefulWidget {
  const CustomAddPage({super.key});

  @override
  State<CustomAddPage> createState() => _CustomAddPageState();
}

class _CustomAddPageState extends State<CustomAddPage> {
  final _formKey = GlobalKey<FormState>();
  double? value = 0.0;
  int cardNum = 1;
  IconData? _icon = Icons.quiz_rounded;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
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
            "Create a Set",
            style: TextStyle(
                fontWeight: FontWeight.bold
            ),
          ),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                child: GestureDetector(
                  onTap: () async {
                    value = null;
                    final navigator = Navigator.of(context);
                    List<String> termsList = [], defsList = [];
                    for (int i = 0; i < cardNum; i++) {
                      termsList.add(terms?.object[i] ?? "");
                      defsList.add(defs?.object[i] ?? "");
                    }
                    if (_formKey.currentState!.validate()) {
                      await (await SharedPreferences.getInstance()).setInt("currentSet", await Database.insertSet(CardSet(await Database.getNextPosition(), ((title?.object == null) ? "" : title?.object), ((desc?.object == null) ? "" : desc?.object), _icon!, termsList, defsList)));
                      
                      navigator.popAndPushNamed("/HOME/SET");
                    }
                    value = 0.0;
                  },
                  child: Icon(
                    Icons.check_rounded,
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
                BetterTextFormField("Enter a title", null, true, "A title is required", title),
                BetterTextFormField("Enter a description (Optional)", null, false, null, desc),
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
                for (int i = 0; i < cardNum; i++) Padding(padding: const EdgeInsets.only(bottom: 5), child: BetterCardTextForm("Enter a term", "Enter a definition", i, terms, defs),),
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
}