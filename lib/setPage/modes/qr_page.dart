import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: LocalDatabase.getString(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Scaffold(
                appBar: BetterAppBar("QR Code", null,
                    Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                          ),
                        )
                    ), null),
                body:
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: PageView.builder(
                            itemCount: snapshot.data.length,
                            controller: controller,
                            onPageChanged: (int index) => setState(() => _index = index),
                            itemBuilder: (_, i) {
                              return
                                Transform.scale(
                                scale: i == _index ? 1.35 : 0.90,
                                child:
                                  Center(
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                  child: QrImage(
                                    data: snapshot.data[i],
                                    version: QrVersions.auto,
                                    // size: MediaQuery.of(context).size.width,
                                    errorCorrectionLevel: QrErrorCorrectLevel.L,
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                  ),
                                  ),
                                  ])),
                              );
                            },
                          ),
                        ),
                      Text("${_index+1}/${snapshot.data.length}",
                          style: TextStyle(
                          color: MediaQuery.of(context).platformBrightness != Brightness.light ? Colors.white : Colors.black,
                          fontSize: MediaQuery.of(context).size.height * 0.036,
                          fontWeight: FontWeight.bold
                      )),
                      Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1))
                    ]
                  ),
                ),
            );
          }
          else if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
            return const Text('', semanticsLabel: '',);
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
                body: ListView(children:  [
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