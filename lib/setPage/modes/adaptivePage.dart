import 'package:flutter/material.dart';

import '../../widgets.dart';

class AdaptivePage extends StatelessWidget {

  const AdaptivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const BetterAppBar("AP Chem", null, true),
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