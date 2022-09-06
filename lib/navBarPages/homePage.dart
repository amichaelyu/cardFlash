import 'package:card_flash/database.dart';
import 'package:card_flash/widgets.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Database.getTitles(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 5),
              child: ListView(
                children: [
                  for (var set in snapshot.data) BetterCardHome(set['title'], set['desc'], IconData(set['iconCP'], fontFamily: set['iconFF'], fontPackage: set['iconFP']), set['titleID'], '/HOME/SET')
                ]
            ),
            );
          }
          else if ((snapshot.connectionState == ConnectionState.none) || (snapshot.connectionState == ConnectionState.waiting)) {
            return const Text("");
          }
          else {
            return ListView(children: const [Padding(padding: EdgeInsets.only(top: 20), child: Align(alignment: Alignment.center, child: Text("No sets", style: TextStyle(fontSize: 20,),),),)]);
          }
        }
    );
  }
}