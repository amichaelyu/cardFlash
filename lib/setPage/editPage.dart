import 'package:card_flash/database.dart';
import 'package:flutter/material.dart';

import '../widgets.dart';

class EditPage extends StatelessWidget {
  final data = CardSet(0, "AP Chemistry", "Weird Set", Icons.science_rounded, ["acetate", "suitcase/luggage", "What kind of ticket would you like?", "Charles I"], ["C₂H₃O₂⁻", "une valise", "quelle sorte de billet désirez-vous?", "King of England and son of James I. His power struggles with Parliament resulted in the English Civil War (1642-1648) in which he was defeated, tried for treason and beheaded in 1649"]);

  EditPage({super.key});

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
          ),
        ),
        body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(0),
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      onPressed: () {
                        Database.insertSet(data);
                      },
                      child: const Text("Submit",
                        style: TextStyle(fontSize: 25),
                      ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0),
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Database.debugDB();
                    },
                    child: const Text("Read",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0),
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Database.clearTables();
                    },
                    child: const Text("Clear",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ),
            ]
        )
    );
  }
}