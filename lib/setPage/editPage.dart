import 'package:card_flash/database.dart';
import 'package:flutter/material.dart';

import '../widgets.dart';

class EditPage extends StatelessWidget {
  final data = CardSet(0, "AP Chemistry", "Weird Set", Icons.science_rounded, ["acetate", "suitcase/luggage", "What kind of ticket would you like?", "Charles I"], ["C₂H₃O₂⁻", "une valise", "quelle sorte de billet désirez-vous?", "King of England and son of James I. His power struggles with Parliament resulted in the English Civil War (1642-1648) in which he was defeated, tried for treason and beheaded in 1649"]);

  EditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Database.getData(),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (snapshot.data != null) {
      }
      return Text('data');
    }
    );
  }
}