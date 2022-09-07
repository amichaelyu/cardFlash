import 'package:flutter/material.dart';

import '../../widgets.dart';

class QRImportPage1 extends StatelessWidget {

  const QRImportPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BetterAppBar("QR Import", null, Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/ADD');
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
              ),
            )
        ),null),
        body: const Text("")
    );
  }
}