import 'package:card_flash/constants.dart';
import 'package:card_flash/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database.dart';

class SetPage extends StatefulWidget {
  const SetPage({super.key});

  @override
  State<SetPage> createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  int _index = 0;
  late int colorLight;
  late int colorDark;

  _initializeColor() async {
    colorLight = (await SharedPreferences.getInstance()).getInt("cardColorLight")!;
    colorDark = (await SharedPreferences.getInstance()).getInt("cardColorDark")!;
  }

  @override
  void initState() {
    super.initState();
    _initializeColor();
    _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Database.getSetStream(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Scaffold(
                appBar: BetterAppBar(snapshot.data.first['title'],
                    <Widget>[
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/HOME/SET/EDIT");
                            },
                            child: Icon(
                              Icons.edit_rounded,
                              color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black : Colors.white,
                            ),
                          )
                      )
                    ]
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
                  ),null),
                body: ListView(
                    children: [
                      Padding(
                        padding: snapshot.data.first['desc'] == ""
                            ? EdgeInsets.zero
                            : const EdgeInsets.fromLTRB(10, 0, 10, 15),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(snapshot.data.first['desc'],
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: SizedBox(
                          height: 400, // card height
                          child: PageView.builder(
                            itemCount: snapshot.data.length - 1,
                            controller: PageController(
                              viewportFraction: 0.8),
                            onPageChanged: (int index) => setState(() => _index = index),
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
                                  child: ListView(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(
                                              15),
                                          child: Text(
                                            snapshot.data[i + 1]['term'],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 27),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets
                                              .fromLTRB(10, 0, 10, 0),
                                          child: Text(
                                            snapshot.data[i + 1]['def'],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 20),
                                          ),
                                        ),
                                      ]
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const BetterCardSet(
                          "Flashcards", Icons.style_rounded, "/HOME/SET/FLASHCARDS"),
                      const BetterCardSet(
                          "Adaptive", Icons.memory_rounded, "/HOME/SET/ADAPTIVE"),
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
              ),
              null),
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