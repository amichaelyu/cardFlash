import 'package:flutter/material.dart';

import '../../widgets.dart';

class AdaptivePage extends StatelessWidget {

  const AdaptivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BetterAppBar("AP Chem", null, Padding(
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
        body: Column(
            children: const [
              Padding(
                padding: EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("rat",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ]
        )
    );
  }
}