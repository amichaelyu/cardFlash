import 'package:flutter/material.dart';

import '../widgets.dart';

class AddPage extends StatelessWidget {

  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: ListView(
        children: const [
          BetterCardAdd("Create a Custom Set", "Make your own set from scratch", Icons.color_lens_rounded, "/HOME/CUSTOM"),
          // Center(
          //   child: Card(
          //     elevation: 4,
          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          //     child: InkWell(
          //       splashColor: Colors.blue.withAlpha(30),
          //       onTap: () {
          //         Navigator.pushNamed(context, "/HOME/QUIZLET");
          //       },
          //       child: SizedBox(
          //         width: 370,
          //
          //         child: Column(
          //           children: const <Widget>[
          //             ListTile(
          //               leading: Text(
          //                 "Q",
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 25,
          //                 ),
          //               ),
          //               title: Text(
          //                 "Import a Set from Quizlet",
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 20,
          //                 ),
          //               ),
          //               subtitle: Text("The set must be public"),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // BetterCard4("Import a Set using QR", "You can only import other cardFlash sets", Icons.qr_code, "/HOME/QR1"),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Align(
              alignment: Alignment.center,
              child: Text("More options to come!",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ]
      )
    );
  }
}