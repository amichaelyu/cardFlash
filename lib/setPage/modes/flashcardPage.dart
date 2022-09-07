import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../database.dart';
import '../../widgets.dart';
import '../setPage.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final width = 350.0;
  int _index = 0;
  late List<String> text = [];

  _loadTerms() async {
    var set = await Database.getSetFuture();
    for (int i = 0; i < set.length - 1; i++) {
      text.add(set[i+1]['term']);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Database.getSetStream(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Scaffold(
                appBar: BetterAppBar(snapshot.data.first['title'], <Widget>[
                Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: GestureDetector(
                  onTap: () {
                  },
                  child: const Icon(
                    Icons.more_vert_rounded,
                    size: 30,
                  ),
                )
                )]
                  , Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
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
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                        child: SizedBox(
                          height: 650, // card height
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
                                      ? color[200]
                                      : color[900],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20)),
                                  child: InkWell(
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () async {
                                      setState(() {
                                        if (text[i] == snapshot.data[i + 1]['term']) {
                                          text[i] = snapshot.data[i + 1]['def'];
                                        }
                                        else {
                                          text[i] = snapshot.data[i + 1]['term'];
                                        }
                                      });
                                    },
                                    child: SizedBox(
                                      width: 380,
                                      child: Center(
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                              Padding(
                                                padding: const EdgeInsets
                                                    .all(10),
                                                child: Text(
                                                  text[i],
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 30),
                                                ),
                                              )
                                            ],
                                          ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Row(
                      //   children: const [
                      //     BetterCardFlash(
                      //         "Flashcards", "", Icons.style_rounded,
                      //         "/SET/FLASHCARDS"),
                      //     BetterCardFlash(
                      //         "Adaptive", "", Icons.memory_rounded,
                      //         "/SET/ADAPTIVE"),
                      //   ],
                      // )
                    ]
                )
            );
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
                ),null),
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