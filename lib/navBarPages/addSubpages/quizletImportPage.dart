import 'package:card_flash/widgets.dart';
import 'package:flutter/material.dart';

class QuizletImportPage extends StatelessWidget {

  const QuizletImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
        child: Column(
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