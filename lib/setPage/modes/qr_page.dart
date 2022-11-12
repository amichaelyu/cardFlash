import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../database.dart';
import '../../widgets.dart';

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  final controller = PageController(viewportFraction: 0.8);
  double? value = 0;

  @override
  void initState() {
    value = 0;
    super.initState();
  }

  Future<dynamic> paste() async {
    value = null;
    setState(() {});
    var dio = Dio();
    var prefs = await SharedPreferences.getInstance();
    var titleID = prefs.getInt("currentTitleID")!;
    var pastee = prefs.getStringList("pasteee")!;
    try {
      var id = pastee[titleID];
      if (id.isEmpty) {
        throw Error();
      }
      var response = await dio.get(
        "https://api.paste.ee/v1/pastes/$id",
        queryParameters: {
          'key': Constants.pasteAPIKey,
        },
      );
      if (response.data['success']) {
        value = 0;
        return id;
      } else {
        pastee.removeAt(titleID);
        await prefs.setStringList("pasteee", pastee);
      }
    } catch (exception) {
      //  not needed
    }
    var data = await LocalDatabase.getString();
    var response = await dio.post(
      "https://api.paste.ee/v1/pastes",
      data: {
        'key': Constants.pasteAPIKey,
        "expiration": 86400,
        'sections': [
          {"contents": data}
        ]
      },
    );
    if (response.data['success']) {
      for (int i = pastee.length; i <= titleID; i++) {
        pastee.add('');
      }
      pastee[titleID] = response.data['id'];
      await prefs.setStringList("pasteee", pastee);
      value = 0;
      return response.data['id'];
    } else {
      value = 0;
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: paste(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Scaffold(
              appBar: BetterAppBar(
                  "QR Code",
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
                PreferredSize(
                  preferredSize: const Size(double.infinity, 1.0),
                  child: LinearProgressIndicator(
                    value: value,
                    semanticsLabel:
                    "Checks form and then submits it into the database",
                  ),
                ),),
              body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: QrImage(
                                data: snapshot.data,
                                version: QrVersions.auto,
                                // size: MediaQuery.of(context).size.width,
                                errorCorrectionLevel: QrErrorCorrectLevel.L,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ])),
                      Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height * 0.1))
                    ]),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return Scaffold(
                appBar: BetterAppBar(
                    "QR Code",
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
                  PreferredSize(
                    preferredSize: const Size(double.infinity, 1.0),
                    child: LinearProgressIndicator(
                      value: value,
                      semanticsLabel:
                      "Checks form and then submits it into the database",
                    ),
                  ),),
                body: const Text(
                  '',
                  semanticsLabel: '',
                ));
          } else {
            return Scaffold(
                appBar: BetterAppBar(
                    "QR Code",
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
                          fontSize: MediaQuery.of(context).size.height * 0.024,
                        ),
                      ),
                    ),
                  )
                ]));
          }
        });
  }
}