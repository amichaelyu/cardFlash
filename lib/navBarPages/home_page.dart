import 'package:card_flash/database.dart';
import 'package:card_flash/navBarPages/settings_page.dart';
import 'package:card_flash/widgets.dart';
import 'package:dio/dio.dart';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

import '../constants.dart';
import 'add_page.dart';

var folderName = "";

class HomeNavigator extends StatelessWidget {
  const HomeNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) {
          if (settings.name == '/HOME/FOLDER') {
            return MaterialPageRoute(builder: (_) => const FolderPage());
          } else if (settings.name == '/HOME') {
            return MaterialPageRoute(builder: (_) => const _HomePage());
          }
          else if (settings.name != "/") {
            Navigator.pushNamed(context, settings.name.toString());
          }
          return MaterialPageRoute(builder: (_) => const _HomePage());
        },
      ),
      // body: Center(
      //   child: _HomePage(),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_rounded),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue[500],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: ((index) async {
          final navigator = Navigator.of(context);
          (await SharedPreferences.getInstance()).setInt("currentFolderID", 0);
          switch (index) {
            case 0: {
              break;
            }
            case 1: {
              navigator.push(
                PageRouteBuilder(
                  settings: const RouteSettings(name: "/ADD"),
                  pageBuilder: (c, a1, a2) => const AddNavigator(),
                  transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 0),
                ),
              );
              break;
            }
            case 2: {
              navigator.push(
                PageRouteBuilder(
                  settings: const RouteSettings(name: "/SETTINGS"),
                  pageBuilder: (c, a1, a2) => const SettingsNavigator(),
                  transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 0),
                ),
              );
              break;
            }
            default:
              break;
          }
        }),
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final _formKey = GlobalKey<FormState>();
  final Wrapper _title = Wrapper(null);
  final Wrapper _desc = Wrapper(null);
  int _selectedFolderPos = -1;
  int key = 0;

  @override
  void initState() {
    super.initState();
    checkNav();
    _selectedFolderPos = -1;
  }

  checkNav() async {
    final navigator = Navigator.of(context);
    if ((await SharedPreferences.getInstance()).getInt("currentFolderID") != 0) {
      await navigator.pushNamed("/HOME/FOLDER");
    }
    await Future.delayed(const Duration(milliseconds: 100));
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {});
  }

  move(var snapshot, int position) async {
    if (_selectedFolderPos != -1) {
      final nav = Navigator.of(context, rootNavigator: true);
      await LocalDatabase.updateSetFolder(snapshot.data[_selectedFolderPos]["folderID"], snapshot.data[position]["titleID"]);
      nav.pop('dialog');
      setState(() {});
      _selectedFolderPos = -1;
    }
  }

  delete(var snapshot, var index) async {
    Navigator.of(context, rootNavigator: true).pop('dialog');
    if (snapshot.data[index]['titleID'] != null) {
      await LocalDatabase.deleteSet(snapshot.data[index]['titleID']);
    }
    else {
      await LocalDatabase.deleteFolder(snapshot.data[index]['folderID']);
    }
  }

  nav(var id, var name) async {
    final navigator = Navigator.of(context);
    if (id < 0) {
      (await SharedPreferences.getInstance()).setInt("currentFolderID", - (id + 1));
      folderName = name;
      await navigator.pushNamed("/HOME/FOLDER");
      await Future.delayed(const Duration(milliseconds: 100));
      FocusManager.instance.primaryFocus?.unfocus();
    }
    else {
      (await SharedPreferences.getInstance()).setInt("currentFolderID", 0);
      (await SharedPreferences.getInstance()).setInt("currentTitleID", id - 1);
      await navigator.pushNamed("/HOME/SET");
      await Future.delayed(const Duration(milliseconds: 100));
      FocusManager.instance.primaryFocus?.unfocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BetterAppBar(Constants.title, <Widget>[
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
            child: ExpandTapWidget(
                        tapPadding: const EdgeInsets.all(5.0),
              onTap: () async {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    insetPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    title: const Text(
                        'Create a new folder',
                        semanticsLabel:
                        "Create a new folder"),
                    content: Form(
                        key: _formKey,
                        child: SizedBox(
                          width: double.maxFinite,
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BetterTextFormField(
                                'Enter a title',
                                null,
                                false,
                                "A title is required!",
                                _title,
                                null,
                                null
                            ),
                            BetterTextFormField(
                                'Enter a description',
                                null,
                                false,
                                null,
                                _desc,
                                null,
                                null
                            ),
                          ],
                        ),
                        ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            semanticsLabel: "Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final navigator = Navigator.of(context);
                            ScaffoldMessenger.of(context)
                                .clearSnackBars();
                            await LocalDatabase.insertFolder(Folder(await LocalDatabase.getNextPositionFolder(), _title.object, ((_desc.object == null) ? "" : _desc.object)));
                            (await SharedPreferences.getInstance()).setInt("currentFolderID", 0);
                            navigator.push(PageRouteBuilder(
                              pageBuilder: (c, a1, a2) => const HomeNavigator(),
                              settings:
                              const RouteSettings(name: "/HOME"),
                              transitionDuration: Duration.zero,
                            ));
                          }
                        },
                        child: const Text(
                          'Ok',
                          semanticsLabel: "Ok",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Icon(
                Icons.add_rounded,
                color: MediaQuery.of(context).platformBrightness ==
                    Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ))
      ], null, null),
      body: FutureBuilder(
        future: LocalDatabase.getHomeData(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 5),
              child: ReorderableListView.builder(
                onReorder: (int oldIndex, int newIndex) async {
                  int folderNum = await LocalDatabase.getFoldersNum();
                  if (snapshot.data[oldIndex]['titleID'] == null && newIndex < folderNum) {
                    await LocalDatabase.updateFolderPosition(
                        oldIndex, newIndex, snapshot.data[oldIndex]['folderID']);
                  }
                  else if (newIndex >= folderNum) {
                    await LocalDatabase.updateSetPosition(
                        oldIndex - folderNum, newIndex - folderNum,
                        snapshot.data[oldIndex]['titleID']);
                  }
                  setState(() {});
                },
                itemBuilder: (BuildContext context, int index) {
                  return Slidable(
                      key: Key((snapshot.data[index]['titleID'] != null ? snapshot.data[index]['titleID'] + 1 : - snapshot.data[index]['folderID'] - 1).toString()),
                      endActionPane: (snapshot.data[index]['titleID'] != null ? ActionPane(
                          extentRatio: 0.45,
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                      StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                            title: const Text('Choose a folder', semanticsLabel: 'Choose a folder',),
                                            insetPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                            content: SizedBox(
                                                width: double.maxFinite,
                                                height: MediaQuery.of(context).size.height * 0.6,
                                                child: ListView.builder(
                                                  itemBuilder: (BuildContext context, int index) {
                                                    return snapshot.data[index]['folderID'] != null ? Card(
                                                        elevation: 4,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                        color: _selectedFolderPos == index ? (MediaQuery.of(context).platformBrightness == Brightness.light ? Constants.lightModeSplash : Constants.darkModeSplash) : null,
                                                        child: Center(
                                                            child: InkWell(
                                                          borderRadius: BorderRadius.circular(15),
                                                          splashColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Constants.lightModeSplash : Constants.darkModeSplash,
                                                          onTap: () async {
                                                            _selectedFolderPos = _selectedFolderPos == index ? -1 : index;
                                                            setState(() {});
                                                          },
                                                          child: SizedBox(
                                                            height: MediaQuery.of(context).size.width * 0.15,
                                                            width: MediaQuery.of(context).size.width * 0.95,
                                                              child: ListTile(
                                                              leading: Icon(
                                                                  IconData(snapshot.data[index]['iconCP'], fontFamily: snapshot.data[index]['iconFF'] == "" ? null : snapshot.data[index]['iconFF'], fontPackage: snapshot.data[index]['iconFP'] == "" ? null : snapshot.data[index]['iconFP'])),
                                                              title:
                                                                  // pa: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.01, 0, 0),
                                                                  Text(
                                                                      snapshot
                                                                          .data[index]['title'],
                                                                      semanticsLabel: snapshot
                                                                          .data[index]['title'],
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize: MediaQuery
                                                                              .of(
                                                                              context)
                                                                              .size
                                                                              .height *
                                                                              0.024)),
                                                            )),
                                                          )),
                                                        ) : const SizedBox(width: 0, height: 0,);
                                                  },
                                                  itemCount: snapshot.data.length,
                                                    )
                                          ),
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  _selectedFolderPos = -1;
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel',
                                                    semanticsLabel: 'Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    move(snapshot, index);
                                                  });
                                                },
                                                child: const Text(
                                                  'Confirm',
                                                  semanticsLabel: 'Confirm',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          );
                                      }
                                      )
                                  );
                              },
                              backgroundColor: const Color(0xff0062cc),
                              foregroundColor: Colors.white,
                              icon: Icons.folder_copy_rounded,
                              label: 'Move',
                            ),
                            SlidableAction(
                              onPressed: (context) async {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('Are you sure you want to delete this set?', semanticsLabel: 'Are you sure you want to delete this set?',),
                                      content: const Text('This process is currently irreversible!', semanticsLabel: 'This process is currently irreversible!',),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel', semanticsLabel: 'Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              delete(snapshot, index);
                                            });
                                          },
                                          child: const Text(
                                            'Confirm',
                                            semanticsLabel: 'Confirm',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ));
                              },
                              backgroundColor: const Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete_rounded,
                              label: 'Delete',
                            ),
                          ]
                      ) : ActionPane(
                          extentRatio: 0.225,
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('Are you sure you want to delete this folder?', semanticsLabel: 'Are you sure you want to delete this folder?',),
                                      content: const Text('This process is currently irreversible!', semanticsLabel: 'This process is currently irreversible!',),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel', semanticsLabel: 'Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              delete(snapshot, index);
                                            });
                                          },
                                          child: const Text(
                                            'Confirm',
                                            semanticsLabel: 'Confirm',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ));
                              },
                              backgroundColor: const Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete_rounded,
                              label: 'Delete',
                            ),
                          ]
                      )),
                      child: (snapshot.data[index]['titleID'] != null ?
                      Center(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            splashColor: MediaQuery.of(context).platformBrightness == Brightness.light ?  Constants.lightModeSplash :  Constants.darkModeSplash,
                            onTap: () {
                              setState(() {
                                nav(snapshot.data[index]['titleID'] != null ? snapshot.data[index]['titleID'] + 1 : - snapshot.data[index]['folderID'] - 1, snapshot.data[index]['title']);
                              });
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.95,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(IconData(snapshot.data[index]['iconCP'], fontFamily: snapshot.data[index]['iconFF'] == "" ? null : snapshot.data[index]['iconFF'], fontPackage: snapshot.data[index]['iconFP'] == "" ? null : snapshot.data[index]['iconFP'])),
                                    title: Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text(snapshot.data[index]['title'], semanticsLabel: snapshot.data[index]['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                                    subtitle: Text(snapshot.data[index]['desc'], semanticsLabel: snapshot.data[index]['desc'],),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      TextButton(
                                        child: const Text('STUDY', semanticsLabel: 'STUDY',),
                                        onPressed: () async {
                                          if (snapshot.data[index]['titleID'] != null) {
                                            final navigator = Navigator.of(
                                                context);
                                            (await SharedPreferences
                                                .getInstance()).setInt(
                                                "currentTitleID", snapshot
                                                .data[index]['titleID']);
                                            navigator.pushNamed(
                                                '/HOME/SET/ADAPTIVE');
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ) : Center(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            splashColor: MediaQuery.of(context).platformBrightness == Brightness.light ?  Constants.lightModeSplash :  Constants.darkModeSplash,
                            onTap: () {
                            setState(() {
                            nav(snapshot.data[index]['titleID'] != null ? snapshot.data[index]['titleID'] + 1 : - snapshot.data[index]['folderID'] - 1, snapshot.data[index]['title']);
                            });
                            },
                            child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            height: MediaQuery.of(context).size.width * 0.25,
                            child:
                            ListTile(
                            leading: Icon(IconData(snapshot.data[index]['iconCP'], fontFamily: snapshot.data[index]['iconFF'] == "" ? null : snapshot.data[index]['iconFF'], fontPackage: snapshot.data[index]['iconFP'] == "" ? null : snapshot.data[index]['iconFP'])),
                            title: Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text(snapshot.data[index]['title'], semanticsLabel: snapshot.data[index]['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                            subtitle: Text(snapshot.data[index]['desc'], semanticsLabel: snapshot.data[index]['desc'],),
                            ),
                            ),
                  ),
                        ),
                    ))
                    );
                },
                itemCount: snapshot.data.length,
              )
            );
          }
          else if ((snapshot.connectionState == ConnectionState.none) || (snapshot.connectionState == ConnectionState.waiting)) {
            return const Text("", semanticsLabel: "");
          }
          else {
            return Column(children: [Padding(padding: const EdgeInsets.only(top: 20), child: Align(alignment: Alignment.center, child: Text("No sets", semanticsLabel: "No sets", style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.026,),),),)]);
          }
        }
      ),
    );
  }
}

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  num _selectedFolderPos = -1;
  final _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // monitor network fetch
    await refresh();
    // await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  move(var snapshot, int position) async {
    if (_selectedFolderPos != -1) {
      final nav = Navigator.of(context, rootNavigator: true);
      final folders = await LocalDatabase.getFolders();
      await LocalDatabase.updateSetFolder(_selectedFolderPos == 0 ? -1 : folders[_selectedFolderPos-1]["folderID"], snapshot.data[position]["titleID"]);
      nav.pop('dialog');
      setState(() {});
      _selectedFolderPos = -1;
    }
  }

  delete(var snapshot, var index) async {
    Navigator.of(context, rootNavigator: true).pop('dialog');
    if (snapshot.data[index]['titleID'] != null) {
      await LocalDatabase.deleteSet(snapshot.data[index]['titleID']);
    }
    else {
      await LocalDatabase.deleteFolder(snapshot.data[index]['folderID']);
    }
  }

  nav(var id, var name) async {
    final navigator = Navigator.of(context);
    if (id < 0) {
      (await SharedPreferences.getInstance()).setInt("currentFolderID", - (id + 1));
      folderName = name;
      await navigator.pushNamed("/HOME/FOLDER");
      await Future.delayed(const Duration(milliseconds: 100));
      FocusManager.instance.primaryFocus?.unfocus();
    }
    else {
      (await SharedPreferences.getInstance()).setInt("currentTitleID", id - 1);
      await navigator.pushNamed("/HOME/SET");
      await Future.delayed(const Duration(milliseconds: 100));
      FocusManager.instance.primaryFocus?.unfocus();
    }
    setState(() {});
  }

  loadCurrentFolder() async {
    _selectedFolderPos = (await LocalDatabase.getFolderPosition((await SharedPreferences.getInstance()).getInt("currentFolderID")!))[0]['position'];
    folderName = (await LocalDatabase.getFolders())[_selectedFolderPos]['title'];
  }

  refresh() async {
    List<String> titles = [];
    List<String> descs = [];
    List<List<String>> terms = [];
    List<List<String>> defs = [];
    var mess = ScaffoldMessenger.of(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var userToken = prefs.getString("interSubUserToken");

    var dio = Dio();
    // request auth key using userToken
    Response? response;
    try {
      response = await dio.post(
        "https://app.intersub.cc/api/public/auth-token",
        data: {
          'appId': Platform.isIOS ? Constants.interSubiOSAPIKey : Constants
              .interSubAndroidAPIKey,
          'metadata': "cardFlash on ${Platform.isIOS ? "iOS" : Platform
              .isAndroid ? "Android" : "Unknown"}",
          'userToken': userToken,
        },
        queryParameters: {
          'accept': "application/vnd.intersub.auth-token.response.v1+json",
          'content-type': "application/json",
        },
      );
    }
    on DioException catch(e){
      if (e.response?.statusCode == 409) {
        response = await dio.post(
          "https://app.intersub.cc/api/public/auth-token",
          data: {
            'appId': Platform.isIOS ? Constants.interSubiOSAPIKey : Constants
                .interSubAndroidAPIKey,
            'metadata': "cardFlash on ${Platform.isIOS ? "iOS" : Platform
                .isAndroid ? "Android" : "Unknown"}",
            'userToken': userToken,
            "resetToken": e.response?.data['resetToken']
          },
          queryParameters: {
            'accept': "application/vnd.intersub.auth-token.response.v1+json",
            'content-type': "application/json",
          },
        );
      }
      else {
        var message = 'Something went wrong!';
        if (e.response?.statusCode == 400) message = "Invalid User ID format!";
        if (e.response?.statusCode == 401) message = "User ID not found!";
        mess.clearSnackBars();
        mess.showSnackBar(
          SnackBar(
            backgroundColor: Colors.black87,
            content: Text(
              message,
              semanticsLabel: message,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            duration: const Duration(milliseconds: 5000),
          ),
        );
      }
    }

    if (response != null) {
      // if good response from API
      try {
        // request data from api with auth key
        var response2 = await dio.post(
          "https://app.intersub.cc/api/public/usage/lookups",
          data: {
            "pageRequest": {
              "pageRequestDto": {
                "page": 0,
                "size": 100,
                "sort": {
                  "orders": []
                }
              },
              "zoneId": "UTC"
            },
            "lookupPeriod": "ALL_TIME",
            "inUserDictionary": true,
            "sort": "LAST_REQUEST_CREATION_TIMESTAMP_DESCENDING"
          },
          queryParameters: {
            'accept': "application/vnd.intersub.usage.translation-history.response-with-lookup-period.v3+json",
          },
          options: Options(contentType: "application/json",
            headers: {'x-auth-token': response.data['authToken']},),
        );
        // - If auth token has invalid format: HTTP code 400
        // - If auth token was not found: HTTP code 401
        // - If the user has “Free” plan: HTTP code 402
        var titlesDatabase = (await LocalDatabase.getTitlesInFolder()) ?? {};
        var allWords = -1;
        for (int i = 0; i < titlesDatabase.length; i++) {
          titles.add(titlesDatabase[i]['title']);
          descs.add(titlesDatabase[i]['desc']);
          if (titlesDatabase[i]['title'] == "All Words") {
            allWords = i;
          }
          terms.add([]);
          defs.add([]);
          var setDatabase = await LocalDatabase.getSetWithTitleID(
              titlesDatabase[i]['titleID']);
          for (int z = 1; z < setDatabase.length; z++) {
            terms[i].add(setDatabase[z]['term']);
            defs[i].add(setDatabase[z]['def']);
          }
        }

        var allTerms = [];
        var allDefs = [];

        var morePages = true;
        var currentPage = 0;
        while (morePages) {
          morePages = false;
          // process all the terms
          for (int i = 0; i < response2.data['items']['content'].length; i++) {
            // store current item for conciseness
            var item = response2.data['items']['content'][i]['item'];

            // check if current title has already been stored
            if (!titles.contains(item['request']['params']['videoTitle'])) {
              titles.add(item['request']['params']['videoTitle']);
            }

            // find current title index
            int titleIndex = titles.indexOf(
                item['request']['params']['videoTitle']);

            // add new terms List if not enough lists
            if (terms.length < titles.length) {
              terms.add([]);
              defs.add([]);
            }

            // try to add words, sometimes is null so need try catch
            try {
              var baseWord = item['translationResult']['baseWordFormToWordDefinitionListMap']
                  .keys.toList()[0];
              for (int z = 0; z <
                  item['translationResult']['baseWordFormToWordDefinitionListMap'][baseWord][0]['partOfSpeechToDefinitionListMap']
                      .keys
                      .toList()
                      .length; z++) {
                var termText = item['translationResult']['baseWordFormToWordDefinitionListMap'][baseWord][0]['baseWordForm'] +
                    " (" +
                    item['translationResult']['baseWordFormToWordDefinitionListMap'][baseWord][0]['partOfSpeechToDefinitionListMap']
                        .keys.toList()[z] + ")\n—\n" +
                    item['request']['params']['context'];
                var defText = item['translationResult']['baseWordFormToWordDefinitionListMap'][baseWord][0]['partOfSpeechToDefinitionListMap']
                    .values.toList()[z].toString().substring(1,
                    item['translationResult']['baseWordFormToWordDefinitionListMap'][baseWord][0]['partOfSpeechToDefinitionListMap']
                        .values.toList()[z]
                        .toString()
                        .length - 1);
                if (allWords == -1) {
                  allTerms.add(termText);
                  allDefs.add(defText);
                }
                else if (!terms[allWords].contains(termText)) {
                  terms[allWords].add(termText);
                  defs[allWords].add(defText);
                }
                if (!terms[titleIndex].contains(termText)) {
                  terms[titleIndex].add(termText);
                  defs[titleIndex].add(defText);
                }
              }
            }
            catch (err) {
              continue;
            }
          }

          if (response2.data['items']['hasNext']) {
            currentPage++;
            response2 = await dio.post(
              "https://app.intersub.cc/api/public/usage/lookups",
              data: {
                "pageRequest": {
                  "pageRequestDto": {
                    "page": currentPage,
                    "size": 100,
                    "sort": {
                      "orders": []
                    }
                  },
                  "zoneId": "UTC"
                },
                "lookupPeriod": "ALL_TIME",
                "inUserDictionary": true,
                "sort": "LAST_REQUEST_CREATION_TIMESTAMP_DESCENDING"
              },
              queryParameters: {
                'accept': "application/vnd.intersub.usage.translation-history.response-with-lookup-period.v3+json",
              },
              options: Options(contentType: "application/json",
                headers: {'x-auth-token': response.data['authToken']},),
            );
            morePages = response2.statusCode == 200;
          }
        }

        // locate the folder
        var folderPos = await LocalDatabase.getInterSubFolderPos();
        int folderID = (await LocalDatabase.getFolderID(folderPos));

        if (allWords == -1) {
          CardSet set = CardSet(
              await LocalDatabase.getNextPositionSetInFolder(folderID),
              "All Words", "", Icons.flag_rounded, allTerms, allDefs);
          int setID = await LocalDatabase.insertSet(set);
          await LocalDatabase.updateSetFolder(folderID, setID);
        }
        for (int i = 0; i < titles.length; i++) {
          CardSet set = CardSet(
              await LocalDatabase.getNextPositionSetInFolder(folderID),
              titles[i], "", Icons.flag_rounded, terms[i], defs[i]);
          if (i < titlesDatabase.length) {
            set.desc = descs[i];
            set.icon = IconData(titlesDatabase[i]['iconCP'], fontFamily: titlesDatabase[i]['iconFF'], fontPackage: titlesDatabase[i]['iconFP']);
            await LocalDatabase.updateSetWithID(
                set, titlesDatabase[i]['titleID']);
          }
          else {
            int setID = await LocalDatabase.insertSet(set);
            await LocalDatabase.updateSetFolder(folderID, setID);
          }
        }
        setState(() {});
      } on DioException catch (e) {
        String message = 'Something went wrong!';
        if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
          message += ' Auth Token Error!';
        }
        else if (e.response?.statusCode == 402) {
          message += ' You are on the FREE plan!';
        }
        mess.clearSnackBars();
        mess.showSnackBar(
          SnackBar(
            backgroundColor: Colors.black87,
            content: Text(
              message,
              semanticsLabel: message,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            duration: const Duration(milliseconds: 5000),
          ),
        );
      }
    }
    // bad response from API
    dio.close();
  }

  @override
  void initState() {
    super.initState();
    loadCurrentFolder();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: LocalDatabase.getTitlesInFolder(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Scaffold(
              appBar: BetterAppBar(folderName, null,
                Padding(
                // padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: ExpandTapWidget(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  tapPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                  )
                )
                ), null),
              body: folderName == "InterSub" ? SmartRefresher(
                  header: WaterDropMaterialHeader(
                    color: MediaQuery.of(context).platformBrightness != Brightness.light ? Colors.white : Colors.black,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    distance: 30,
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: ReorderableListView.builder(
                      onReorder: (int oldIndex, int newIndex) async {
                        await LocalDatabase.updateSetPosition(oldIndex, newIndex, snapshot.data[oldIndex]['titleID']);
                        setState(() {});
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Slidable(
                            key: Key((snapshot.data[index]['titleID'] != null ? snapshot.data[index]['titleID'] + 1 : - snapshot.data[index]['folderID'] - 1).toString()),
                            endActionPane: (snapshot.data[index]['titleID'] != null ? ActionPane(
                                extentRatio: 0.45,
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) async {
                                      showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return AlertDialog(
                                                      insetPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                                      title: const Text('Choose a folder', semanticsLabel: 'Choose a folder',),
                                                      content: FutureBuilder(
                                                        future: LocalDatabase.getFolders(),
                                                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                                          if (snapshot.data != null) {
                                                          return SizedBox(
                                                            width: MediaQuery.of(context).size.width,
                                                            height: MediaQuery.of(context).size.height * 0.6,
                                                            child: ListView.builder(
                                                              itemBuilder: (BuildContext context, int index) {
                                                                return Card(
                                                                    elevation: 4,
                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                                    color: _selectedFolderPos == index ? (MediaQuery.of(context).platformBrightness == Brightness.light ? Constants.lightModeSplash : Constants.darkModeSplash) : null,
                                                                    child: InkWell(
                                                                      borderRadius: BorderRadius.circular(15),
                                                                      splashColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Constants.lightModeSplash : Constants.darkModeSplash,
                                                                      onTap: () async {
                                                                        _selectedFolderPos = _selectedFolderPos == index ? -1 : index;
                                                                        setState(() {});
                                                                      },
                                                                      child: SizedBox(
                                                                        height: MediaQuery.of(context).size.height * 0.07,
                                                                        width: MediaQuery.of(context).size.width * 0.95,
                                                                        child: ListTile(
                                                                          leading: Padding(
                                                                            padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height * 0.012), child: Icon(IconData(snapshot.data[0]['iconCP'], fontFamily: snapshot.data[0]['iconFF'] == "" ? null : snapshot.data[0]['iconFF'], fontPackage: snapshot.data[0]['iconFP'] == "" ? null : snapshot.data[0]['iconFP'])),),
                                                                          title: Padding(
                                                                              padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height * 0.012),
                                                                              child: Text(
                                                                                  index == 0 ? "(No Folder)" : snapshot.data[index-1]['title'],
                                                                                  semanticsLabel: index == 0 ? "(No Folder)" : snapshot.data[index-1]['title'],
                                                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                                                                        )
                                                                      ),
                                                                    ));
                                                              },
                                                              itemCount: snapshot.data.length + 1,
                                                            )
                                                        );}
                                                          else {return const Text("", semanticsLabel: "");}
                                                        }),
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            _selectedFolderPos = -1;
                                                            Navigator.pop(context);
                                                          },
                                                          child: const Text('Cancel',
                                                              semanticsLabel: 'Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              move(snapshot, index);
                                                            });
                                                          },
                                                          child: const Text(
                                                            'Confirm',
                                                            semanticsLabel: 'Confirm',
                                                            style: TextStyle(
                                                                color: Colors.red),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                              )
                                      );
                                    },
                                    backgroundColor: const Color(0xff0062cc),
                                    foregroundColor: Colors.white,
                                    icon: Icons.folder_copy_rounded,
                                    label: 'Move',
                                  ),
                                  SlidableAction(
                                    onPressed: (context) async {
                                      showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) => AlertDialog(
                                            title: const Text('Are you sure you want to delete this set?', semanticsLabel: 'Are you sure you want to delete this set?',),
                                            content: const Text('This process is currently irreversible!', semanticsLabel: 'This process is currently irreversible!',),
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel', semanticsLabel: 'Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    delete(snapshot, index);
                                                  });
                                                },
                                                child: const Text(
                                                  'Confirm',
                                                  semanticsLabel: 'Confirm',
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ));
                                    },
                                    backgroundColor: const Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete_rounded,
                                    label: 'Delete',
                                  ),
                                ]
                            ) :
                            ActionPane(
                                extentRatio: 0.225,
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) async {
                                      showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) => AlertDialog(
                                            title: const Text('Are you sure you want to delete this folder?', semanticsLabel: 'Are you sure you want to delete this folder?',),
                                            content: const Text('This process is currently irreversible!', semanticsLabel: 'This process is currently irreversible!',),
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel', semanticsLabel: 'Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    delete(snapshot, index);
                                                  });
                                                },
                                                child: const Text(
                                                  'Confirm',
                                                  semanticsLabel: 'Confirm',
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ));
                                    },
                                    backgroundColor: const Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete_rounded,
                                    label: 'Delete',
                                  ),
                                ]
                            )
                            ),
                            child: (snapshot.data[index]['titleID'] != null ?
                            Center(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  splashColor: MediaQuery.of(context).platformBrightness == Brightness.light ?  Constants.lightModeSplash :  Constants.darkModeSplash,
                                  onTap: () {
                                    setState(() {
                                      nav(snapshot.data[index]['titleID'] != null ? snapshot.data[index]['titleID'] + 1 : - snapshot.data[index]['folderID'] - 1, snapshot.data[index]['title']);
                                    });
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.95,
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(IconData(snapshot.data[index]['iconCP'], fontFamily: snapshot.data[index]['iconFF'] == "" ? null : snapshot.data[index]['iconFF'], fontPackage: snapshot.data[index]['iconFP'] == "" ? null : snapshot.data[index]['iconFP'])),
                                          title: Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text(snapshot.data[index]['title'], semanticsLabel: snapshot.data[index]['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                                          subtitle: Text(snapshot.data[index]['desc'], semanticsLabel: snapshot.data[index]['desc'],),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            TextButton(
                                              child: const Text('STUDY', semanticsLabel: 'STUDY',),
                                              onPressed: () async {
                                                if (snapshot.data[index]['titleID'] != null) {
                                                  final navigator = Navigator.of(
                                                      context);
                                                  (await SharedPreferences
                                                      .getInstance()).setInt(
                                                      "currentTitleID", snapshot
                                                      .data[index]['titleID']);
                                                  navigator.pushNamed(
                                                      '/HOME/SET/ADAPTIVE');
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ) : Center(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  splashColor: MediaQuery.of(context).platformBrightness == Brightness.light ?  Constants.lightModeSplash :  Constants.darkModeSplash,
                                  onTap: () {
                                    setState(() {
                                      nav(snapshot.data[index]['titleID'] != null ? snapshot.data[index]['titleID'] + 1 : - snapshot.data[index]['folderID'] - 1, snapshot.data[index]['title']);
                                    });
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.95,
                                    height: MediaQuery.of(context).size.height * 0.125,
                                    child:
                                    ListTile(
                                      leading: Icon(IconData(snapshot.data[index]['iconCP'], fontFamily: snapshot.data[index]['iconFF'] == "" ? null : snapshot.data[index]['iconFF'], fontPackage: snapshot.data[index]['iconFP'] == "" ? null : snapshot.data[index]['iconFP'])),
                                      title: Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text(snapshot.data[index]['title'], semanticsLabel: snapshot.data[index]['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                                      subtitle: Text(snapshot.data[index]['desc'], semanticsLabel: snapshot.data[index]['desc'],),
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        );
                      },
                      itemCount: snapshot.data.length,
                      physics: const ClampingScrollPhysics(),
                  )
              ) : Padding(
                padding: const EdgeInsets.only(top: 5),
                child: ReorderableListView.builder(
                  onReorder: (int oldIndex, int newIndex) async {
                    await LocalDatabase.updateSetPosition(oldIndex, newIndex, snapshot.data[oldIndex]['titleID']);
                    setState(() {});
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return Slidable(
                        key: Key((snapshot.data[index]['titleID'] != null ? snapshot.data[index]['titleID'] + 1 : - snapshot.data[index]['folderID'] - 1).toString()),
                        endActionPane: (snapshot.data[index]['titleID'] != null ? ActionPane(
                            extentRatio: 0.45,
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          StatefulBuilder(
                                              builder: (context, setState) {
                                                return AlertDialog(
                                                  insetPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                                  title: const Text('Choose a folder', semanticsLabel: 'Choose a folder',),
                                                  content: FutureBuilder(
                                                      future: LocalDatabase.getFolders(),
                                                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                                        if (snapshot.data != null) {
                                                          return SizedBox(
                                                              width: MediaQuery.of(context).size.width,
                                                              height: MediaQuery.of(context).size.height * 0.6,
                                                              child: ListView.builder(
                                                                itemBuilder: (BuildContext context, int index) {
                                                                  return Card(
                                                                      elevation: 4,
                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                                      color: _selectedFolderPos == index ? (MediaQuery.of(context).platformBrightness == Brightness.light ? Constants.lightModeSplash : Constants.darkModeSplash) : null,
                                                                      child: InkWell(
                                                                        borderRadius: BorderRadius.circular(15),
                                                                        splashColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Constants.lightModeSplash : Constants.darkModeSplash,
                                                                        onTap: () async {
                                                                          _selectedFolderPos = _selectedFolderPos == index ? -1 : index;
                                                                          setState(() {});
                                                                        },
                                                                        child: SizedBox(
                                                                            height: MediaQuery.of(context).size.height * 0.07,
                                                                            width: MediaQuery.of(context).size.width * 0.95,
                                                                            child: ListTile(
                                                                              leading: Padding(
                                                                                padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height * 0.012), child: Icon(IconData(snapshot.data[0]['iconCP'], fontFamily: snapshot.data[0]['iconFF'] == "" ? null : snapshot.data[0]['iconFF'], fontPackage: snapshot.data[0]['iconFP'] == "" ? null : snapshot.data[0]['iconFP'])),),
                                                                              title: Padding(
                                                                                  padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height * 0.012),
                                                                                  child: Text(
                                                                                      index == 0 ? "(No Folder)" : snapshot.data[index-1]['title'],
                                                                                      semanticsLabel: index == 0 ? "(No Folder)" : snapshot.data[index-1]['title'],
                                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                                                                            )
                                                                        ),
                                                                      ));
                                                                },
                                                                itemCount: snapshot.data.length + 1,
                                                              )
                                                          );}
                                                        else {return const Text("", semanticsLabel: "");}
                                                      }),
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        _selectedFolderPos = -1;
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('Cancel',
                                                          semanticsLabel: 'Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          move(snapshot, index);
                                                        });
                                                      },
                                                      child: const Text(
                                                        'Confirm',
                                                        semanticsLabel: 'Confirm',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                          )
                                  );
                                },
                                backgroundColor: const Color(0xff0062cc),
                                foregroundColor: Colors.white,
                                icon: Icons.folder_copy_rounded,
                                label: 'Move',
                              ),
                              SlidableAction(
                                onPressed: (context) async {
                                  showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        title: const Text('Are you sure you want to delete this set?', semanticsLabel: 'Are you sure you want to delete this set?',),
                                        content: const Text('This process is currently irreversible!', semanticsLabel: 'This process is currently irreversible!',),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel', semanticsLabel: 'Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                delete(snapshot, index);
                                              });
                                            },
                                            child: const Text(
                                              'Confirm',
                                              semanticsLabel: 'Confirm',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ));
                                },
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete_rounded,
                                label: 'Delete',
                              ),
                            ]
                        ) :
                        ActionPane(
                            extentRatio: 0.225,
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        title: const Text('Are you sure you want to delete this folder?', semanticsLabel: 'Are you sure you want to delete this folder?',),
                                        content: const Text('This process is currently irreversible!', semanticsLabel: 'This process is currently irreversible!',),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel', semanticsLabel: 'Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                delete(snapshot, index);
                                              });
                                            },
                                            child: const Text(
                                              'Confirm',
                                              semanticsLabel: 'Confirm',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ));
                                },
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete_rounded,
                                label: 'Delete',
                              ),
                            ]
                        )
                        ),
                        child: (snapshot.data[index]['titleID'] != null ?
                        Center(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              splashColor: MediaQuery.of(context).platformBrightness == Brightness.light ?  Constants.lightModeSplash :  Constants.darkModeSplash,
                              onTap: () {
                                setState(() {
                                  nav(snapshot.data[index]['titleID'] != null ? snapshot.data[index]['titleID'] + 1 : - snapshot.data[index]['folderID'] - 1, snapshot.data[index]['title']);
                                });
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(IconData(snapshot.data[index]['iconCP'], fontFamily: snapshot.data[index]['iconFF'] == "" ? null : snapshot.data[index]['iconFF'], fontPackage: snapshot.data[index]['iconFP'] == "" ? null : snapshot.data[index]['iconFP'])),
                                      title: Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text(snapshot.data[index]['title'], semanticsLabel: snapshot.data[index]['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                                      subtitle: Text(snapshot.data[index]['desc'], semanticsLabel: snapshot.data[index]['desc'],),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        TextButton(
                                          child: const Text('STUDY', semanticsLabel: 'STUDY',),
                                          onPressed: () async {
                                            if (snapshot.data[index]['titleID'] != null) {
                                              final navigator = Navigator.of(
                                                  context);
                                              (await SharedPreferences
                                                  .getInstance()).setInt(
                                                  "currentTitleID", snapshot
                                                  .data[index]['titleID']);
                                              navigator.pushNamed(
                                                  '/HOME/SET/ADAPTIVE');
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ) : Center(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              splashColor: MediaQuery.of(context).platformBrightness == Brightness.light ?  Constants.lightModeSplash :  Constants.darkModeSplash,
                              onTap: () {
                                setState(() {
                                  nav(snapshot.data[index]['titleID'] != null ? snapshot.data[index]['titleID'] + 1 : - snapshot.data[index]['folderID'] - 1, snapshot.data[index]['title']);
                                });
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height: MediaQuery.of(context).size.height * 0.125,
                                child:
                                ListTile(
                                  leading: Icon(IconData(snapshot.data[index]['iconCP'], fontFamily: snapshot.data[index]['iconFF'] == "" ? null : snapshot.data[index]['iconFF'], fontPackage: snapshot.data[index]['iconFP'] == "" ? null : snapshot.data[index]['iconFP'])),
                                  title: Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text(snapshot.data[index]['title'], semanticsLabel: snapshot.data[index]['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                                  subtitle: Text(snapshot.data[index]['desc'], semanticsLabel: snapshot.data[index]['desc'],),
                                ),
                              ),
                            ),
                          ),
                        ))
                    );
                  },
                  itemCount: snapshot.data.length,
                ),
              ),
          );
          }
          else if ((snapshot.connectionState == ConnectionState.none) || (snapshot.connectionState == ConnectionState.waiting)) {
            return const Text("", semanticsLabel: "");
          }
          else {
            return Scaffold(
            appBar: BetterAppBar(
              folderName,
              null,
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                child: ExpandTapWidget(
                        tapPadding: const EdgeInsets.all(5.0),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                  ),
                )
              ),
              null
            ),
            body: folderName == "InterSub" ? SmartRefresher(
              header: WaterDropMaterialHeader(
                color: MediaQuery.of(context).platformBrightness != Brightness.light ? Colors.white : Colors.black,
                backgroundColor: Theme.of(context).colorScheme.background,
                distance: 30,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: Column(children: [Padding(padding: const EdgeInsets.only(top: 20), child: Align(alignment: Alignment.center, child: Text("No sets", semanticsLabel: "No sets", style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.026,),),),)]))
             : Column(children: [Padding(padding: const EdgeInsets.only(top: 20), child: Align(alignment: Alignment.center, child: Text("No sets", semanticsLabel: "No sets", style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.026,),),),)]));
          }
        }
    );
  }
}