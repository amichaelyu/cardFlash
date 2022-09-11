import 'package:card_flash/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_scraper/web_scraper.dart';

import '../../database.dart';

class QuizletImportPage extends StatefulWidget {
  const QuizletImportPage({super.key});

  @override
  State<QuizletImportPage> createState() => _QuizletImportPageState();
}

class _QuizletImportPageState extends State<QuizletImportPage> {
  final link = Object(null);
  double? value = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BetterAppBar(
          "Quizlet Import", null, Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
              ),
            )
        ),
          PreferredSize(
          preferredSize: const Size(double.infinity, 1.0),
          child: LinearProgressIndicator(
            value: value,
            semanticsLabel: "Checks form and then submits it into the database",
          ),
        ),),
        body: DismissKeyboard(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: BetterTextFormField("Enter your quizlet link", null, null, null, link, null, null))
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            value = null;
            final navigator = Navigator.of(context);
            var mess = ScaffoldMessenger.of(context);
            final webScraper = WebScraper(null);
            var title, desc;
            var terms = [];
            var defs = [];
            final SharedPreferences prefs = await SharedPreferences.getInstance();

            if (await webScraper.loadFullURL(link.object)) {
              if (webScraper.getElement('div.SetPage-titleWrapper', []).isNotEmpty) {
                title = webScraper.getElement(
                    'div.SetPage-titleWrapper', [])[0]['title'];
                if (webScraper
                    .getElement('div.SetPageHeader-description', [])
                    .isNotEmpty) {
                  desc = webScraper.getElement(
                      'div.SetPageHeader-description', [])[0]['title'];
                }
                else {
                  desc = '';
                }
                for (int i = 0; i < webScraper
                    .getElement('span.TermText', [])
                    .length; i++) {
                  if (i % 2 == 0) {
                    terms.add(
                        webScraper.getElement('span.TermText', [])[i]['title']);
                  }
                  else {
                    defs.add(
                        webScraper.getElement('span.TermText', [])[i]['title']);
                  }
                }
                await prefs.setInt("currentTitleID", await Database.insertSet(
                    CardSet(await Database.getNextPosition(), title, desc,
                        Icons.quiz_rounded, terms, defs)));
                navigator.popUntil((route) => route.settings.name == "/");
                navigator.pushNamed('/HOME');
                navigator.pushNamed('/HOME/SET');
                navigator.pushNamed('/HOME/SET/EDIT');
              }
              else {
                mess.showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.black87,
                    content: Text(
                      'Something went wrong!\nThe set might be private, try making a copy.',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    duration: Duration(milliseconds: 5000),
                  ),
                );
              }
            }
            else {
              mess.showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.black87,
                  content: Text(
                    'Something went wrong! Are you connected to the internet?',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  duration: Duration(milliseconds: 2000),
                ),
              );
            }
            value = 0.0;
          },
          backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.green[400] : Colors.green[700],
          child: const Icon(Icons.check_rounded),
      ),
    );
  }
}