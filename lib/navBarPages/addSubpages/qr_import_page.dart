import 'package:card_flash/database.dart';
import 'package:dio/dio.dart';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/material.dart';
import 'package:lzstring/lzstring.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../widgets.dart';
import '../home_page.dart';

class QRImportPage extends StatefulWidget {

  const QRImportPage({super.key});

  @override
  State<QRImportPage> createState() => QRImportPageState();
  }

class QRImportPageState extends State<QRImportPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  String data = "";
  int counter = 1;
  String display = "Scan a cardFlash QR Code";
  QRViewController? controller;
  double? value = 0.0;

  @override
  void initState() {
    super.initState();
    data = "";
    counter = 1;
    display = "Scan a cardFlash QR Code";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BetterAppBar("QR Import", const <Widget>[
          /*Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
              child: ExpandTapWidget(
                        tapPadding: const EdgeInsets.all(5.0),
                onTap: () {
                  data = "";
                  counter = 1;
                  display = "Scan a cardFlash QR Code";
                  setState(() {});
                },
                child: Icon(
                  Icons.delete_rounded,
                  color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black : Colors.white,
                ),
              )
          )
          */
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
        )),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child:
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text(
                      display,
                      textAlign: TextAlign.center,
                    ),
                  )
            )
            )
          ],
        ),
    );
  }
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (result?.code != scanData.code) {
        setState(() {
          result = scanData;
          process();
        });
      }
    });
  }

  void process() async {
    value = null;
    setState(() {});
    final navigator = Navigator.of(context);
    var mess = ScaffoldMessenger.of(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final terms = <String>[];
    final defs = <String>[];

    mess.clearSnackBars();
    mess.showSnackBar(
      const SnackBar(
        backgroundColor: Colors.black87,
        content: Text(
          "Processing...",
          semanticsLabel: "Processing...",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        duration: Duration(milliseconds: 5000),
      ),
    );

    var id = result?.code;
    var dio = Dio();
    var response = await dio.get(
      "https://api.paste.ee/v1/pastes/${id!}",
      queryParameters: {
        'key': Constants.pasteAPIKey,
      },
    );
    if (response.data['success']) {
      data = response.data['paste']["sections"][0]["contents"];
      final uncompressed = LZString.decompressFromUTF16Sync(data);
      final list = uncompressed?.split("§¶");
      if (list?.last == "") {
        list?.removeLast();
      }
      for (int i = 5; i < list!.length; i+=2) {
        terms.add(list[i]);
        defs.add(list[i+1]);
      }
      await prefs.setInt("currentTitleID",
          await LocalDatabase.insertSet(CardSet(await LocalDatabase.getNextPositionSet(), list[0], list[1], IconData(int.parse(list[2]), fontFamily: list[3], fontPackage: list[4] == "null" ? null : list[4]), terms, defs))
      );
      navigator.pushReplacement(
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => const HomeNavigator(),
            settings: const RouteSettings(name: "/HOME"),
            transitionDuration: Duration.zero,
          )
      );
      navigator.pushNamed('/HOME/SET');
      navigator.pushNamed('/HOME/SET/EDIT');
      controller?.dispose();
    }
    else {
      mess.clearSnackBars();
      mess.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black87,
          content: Text(
            'Something went wrong!',
            semanticsLabel: 'Something went wrong!',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          duration: Duration(milliseconds: 5000),
        ),
      );
    }
    value = 0.0;
    mess.clearSnackBars();
    dio.close();
    setState(() {});
  }

  @override
  void dispose() {
    controller?.pauseCamera();
    controller?.dispose();
    super.dispose();
  }
}