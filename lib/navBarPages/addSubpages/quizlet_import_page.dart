import 'package:card_flash/widgets.dart';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_scraper/web_scraper.dart';
import '../../database.dart';

class QuizletImportPage extends StatefulWidget {
  const QuizletImportPage({super.key});

  @override
  State<QuizletImportPage> createState() => _QuizletImportPageState();
}

class _QuizletImportPageState extends State<QuizletImportPage> {
  final link = Wrapper(null);
  double? value = 0.0;
  bool? stop = false;
  HeadlessInAppWebView? headlessWebView ;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: BetterAppBar(
            "Quizlet Import", null, Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
              child: ExpandTapWidget(
                        tapPadding: const EdgeInsets.all(5.0),
                onTap: () {
                  headlessWebView?.dispose();
                  ScaffoldMessenger.of(context).clearSnackBars();
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
          body: Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: ListView(
                  children: [
                    BetterTextFormField("Enter your quizlet link", null, null, null, link, null, null),
                    // TODO: deprecated for now
                    // Expanded(
                    //   child: webpage != "" ? webView :
                    //         const Text(
                    //           '1. Paste link and press green check\n2. Sign in to your Quizlet account\n3. Click the green checkmark again',
                    //           semanticsLabel: '1. Paste link and press green check\n2. Sign in to your Quizlet account\n3. Click the green checkmark again',
                    //           style: TextStyle(fontSize: 20),
                    //       ),
                    // )
                  ]
              )
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // TODO: deprecated for now
              // if (webpage == "") {
              //   webpage = link.object;
              //   webView = InAppWebView(
              //       key: const Key("Value"),
              //       initialUrlRequest: URLRequest(
              //         url: WebUri.uri(Uri.parse(webpage)),
              //       ),
              //       onConsoleMessage: (controller, url) async {
              //         html = (await controller.getHtml())!;
              //       }
              //   );
              //   WebView.debugLoggingSettings.enabled = false;
              //   setState(() {});
              // }
              // WebView.debugLoggingSettings.enabled = false;
              value = null;
              setState(() {});
              final navigator = Navigator.of(context);
              var mess = ScaffoldMessenger.of(context);
              final webScraper = WebScraper(null);
              String title, desc;
              var terms = [];
              var defs = [];
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              headlessWebView = HeadlessInAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri.uri(Uri.parse(link.object)),
                  ),
                  onConsoleMessage: (controller, url) async {
                    webScraper.loadFromString((await controller.getHtml())!);
                    if (!stop!) {
                      if (webScraper
                          .getElement('h1', [])
                          .isNotEmpty) {
                        stop = true;
                        // log((await controller.getHtml())!);
                        title = webScraper.getElement(
                            'h1', [])[0]['title'];
                        if (webScraper
                            .getElement('div.SetPageHeader-description', [])
                            .isNotEmpty) {
                          desc = webScraper.getElement(
                              'div.SetPageHeader-description', [])[0]['title'];
                        }
                        else {
                          desc = '';
                        }
                        webScraper.loadFromString(webScraper.getPageContent().replaceAll('<br>', '\n'));
                        for (int i = 0; i < webScraper
                            .getElement('span.TermText', [])
                            .length; i++) {
                          if (i % 2 == 0) {
                            terms.add(
                                webScraper.getElement('span.TermText', [
                                ])[i]['title']);
                          }
                          else {
                            defs.add(
                                webScraper.getElement('span.TermText', [
                                ])[i]['title']);
                          }
                        }
                        // Removed because of new headless web browser
                        //
                        // webScraper.loadFromString(webScraper.getPageContent().replaceAll('<br>', '\n'));
                        // int startingNum = 0;
                        // int endingNum = 0;
                        // for (int i = 0; i < webScraper
                        //     .getElement('span', [])
                        //     .length; i++) {
                        //   if (webScraper.getElement(
                        //       'span.TermText', [])[0]['title'] ==
                        //       webScraper.getElement('span', [])[i]['title']) {
                        //     startingNum = i;
                        //   }
                        //   if (webScraper.getElement(
                        //       'span.TermText', [])[19]['title'] ==
                        //       webScraper.getElement('span', [])[i]['title']) {
                        //     endingNum = i;
                        //     break;
                        //   }
                        // }
                        //
                        // for (int i = endingNum + 1; i <
                        //     endingNum + int.parse(webScraper.getElement(
                        //         'span', [])[startingNum - 1]['title']
                        //         .toString()
                        //         .substring(19, webScraper.getElement(
                        //         'span', [])[startingNum - 1]['title']
                        //         .toString()
                        //         .length - 1)) * 2 - 20; i += 2) {
                        //   if (webScraper.getElement('span', [])[i]['title'] == "Upgrade to remove ads") {
                        //     print("upgrade to remove ads");
                        //     i++;
                        //   }
                        //   terms.add(webScraper.getElement('span', [])[i]['title']);
                        //   print(webScraper.getElement('span', [])[i]['title']);
                        //   if (webScraper.getElement('span', [])[i + 1]['title'] == "Upgrade to remove ads") {
                        //     print("upgrade to remove ads");
                        //     i++;
                        //   }
                        //   print(webScraper.getElement('span', [])[i + 1]['title']);
                        //   defs.add(webScraper.getElement('span', [])[i + 1]['title']);
                        // }
                        await prefs.setInt(
                            "currentTitleID", await LocalDatabase.insertSet(
                            CardSet(await LocalDatabase.getNextPositionSet(), title,
                                desc,
                                Icons.quiz_rounded, terms, defs)));
                        navigator.popUntil((route) => route.settings.name == "/");
                        navigator.pushNamed('/HOME');
                        navigator.pushNamed('/HOME/SET');
                        navigator.pushNamed('/HOME/SET/EDIT');
                      }
                      else {
                        stop = false;
                        mess.clearSnackBars();
                        mess.showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.black87,
                            content: Text(
                              'Something went wrong!\nThe set might be private, try making a copy.',
                              semanticsLabel: 'Something went wrong! The set might be private, try making a copy.',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            duration: Duration(milliseconds: 5000),
                          ),
                        );
                      }
                    }
                    value = 0.0;
                    // setState(() {});
                  });
              headlessWebView?.run();
            },
            backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.green[400] : Colors.green[700],
            child: const Icon(Icons.check_rounded),
          ),
        ));
  }
}