import 'package:flutter/material.dart';

import '../../widgets.dart';

class QRImportPage2 extends StatelessWidget {

  const QRImportPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BetterAppBar("QR Import", null, Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/HOME');
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
              ),
            )
        ),),
        body: const Text("")
    );
  }
}