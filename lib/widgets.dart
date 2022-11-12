import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';

class BetterAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const BetterAppBar(this.title, this.actions, this.leading, this.bottom, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: false,
        leading: leading,
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.white : null,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.white : Colors.black,
          statusBarIconBrightness: MediaQuery.of(context).platformBrightness == Brightness.light ? Brightness.dark : Brightness.light, // android
          statusBarBrightness: MediaQuery.of(context).platformBrightness == Brightness.light ? Brightness.light : Brightness.dark, // ios
        ),
        titleTextStyle: TextStyle(
          color: MediaQuery.of(context).platformBrightness != Brightness.light ? Colors.white : Colors.black,
          fontSize: MediaQuery.of(context).size.height * 0.036,
          fontWeight: FontWeight.bold
        ),
        iconTheme: IconThemeData(color: MediaQuery.of(context).platformBrightness != Brightness.light ? Colors.white : Colors.black),
        title: Text(
          title,
          semanticsLabel: title,
        ),
        actions: actions,
        bottom: bottom,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// homepage
class BetterCardHome extends StatelessWidget {
  final String title;
  final String desc;
  final IconData? icon;
  final String nav;
  final String navCustom;
  final int titleID;

  const BetterCardHome(this.title, this.desc, this.icon, this.titleID, this.nav, this.navCustom, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            nav;
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(icon),
                  title: Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text(title, semanticsLabel: title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
                  subtitle: Text(desc, semanticsLabel: desc,),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('STUDY', semanticsLabel: 'STUDY',),
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        (await SharedPreferences.getInstance()).setInt("currentTitleID", titleID);
                        navigator.pushNamed(navCustom);
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
    );
  }
}

// set page
class BetterCardSet extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String nav;

  const BetterCardSet(this.title, this.icon, this.nav, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.blue.withAlpha(30),
          onTap: () async {
            var scaf = ScaffoldMessenger.of(context);
            await Navigator.pushNamed(context, nav);
            scaf.clearSnackBars();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(icon),
                  title: Text(
                      title,
                      semanticsLabel: title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height * 0.026,
                      ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// flashcards
class BetterCardFlash extends StatelessWidget {
final String title;
final String desc;
final IconData icon;
final String nav;

const BetterCardFlash(this.title, this.desc, this.icon, this.nav, {super.key});

@override
Widget build(BuildContext context) {
  return Center(
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.pushNamed(context, nav);
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,

          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(icon),
                title: Text(
                  title,
                  semanticsLabel: title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.024,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

// add set page
class BetterCardAdd extends StatelessWidget {
  final String title;
  final String desc;
  final Widget icon;
  final String nav;

  const BetterCardAdd(this.title, this.desc, this.icon, this.nav, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Navigator.pushNamed(context, nav);
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,

            child: Column(
              children: <Widget>[
                ListTile(
                  leading: icon,
                  title: Text(
                    title,
                    semanticsLabel: title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height * 0.024,
                    ),
                  ),
                  subtitle: Text(desc, semanticsLabel: desc,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// settings buttons
class BetterCardSettings extends StatelessWidget {
  final String title;
  final Function()? action;
  final Color? color;

  const BetterCardSettings(this.title, this.action, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: color,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.blue.withAlpha(30),
          onTap: action,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.77,
            height: MediaQuery.of(context).size.height * 0.071,
            child: Padding(padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.020, 0, 0), child: Text(title, semanticsLabel: title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.024))),
              ),
            ),
          ),
    );
  }
}

class BetterTextFormField extends StatelessWidget {
  final String title;
  final String? helper;
  final bool? required;
  final String? validationText;
  final Wrapper? submission;
  final String? initial;
  final TextEditingController? controller;
  final bool? big;

  const BetterTextFormField(this.title, this.helper, this.required, this.validationText, this.submission, this.initial, this.controller, {super.key, this.big});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: TextFormField(
        controller: controller,
        autocorrect: false,
        enableSuggestions: false,
        initialValue: initial,
        maxLines: null,
        onChanged: (val) => submission?.object = val,
        validator: (value) {
          if ((required ?? false) && (value == null || value.isEmpty)) {
            return validationText;
          }
          return null;
        },
        decoration: InputDecoration(
          filled: false,
          helperText: helper,
          helperStyle: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.014),
          contentPadding: (big ?? false) ? const EdgeInsets.only(bottom: 10) : EdgeInsets.zero,
          // labelText: title,
          label: AutoSizeText(
            title,
            semanticsLabel: title,
            maxLines: 10,
            minFontSize: 10,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: MediaQuery.of(context).size.height * ((big ?? false) ? 0.04 : 0.021)),
          ),
          // labelStyle: TextStyle(fontSize: MediaQuery.of(context).size.height * (big != null && big ? 0.04 : 0.021)),
        ),
        cursorColor: MediaQuery
            .of(context)
            .platformBrightness == Brightness.light ? Colors.black : Colors
            .white,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.021,
          color: MediaQuery
              .of(context)
              .platformBrightness == Brightness.light ? Colors.black : Colors
              .white,
        ),
      ),
    );
  }
}

class BetterTextFormFieldNumbersOnly extends StatelessWidget {
  final String title;
  final String? helper;
  final bool? required;
  final String? validationText;
  final Wrapper submission;
  final String initial;
  final TextEditingController? controller;
  final int onChanged;

  const BetterTextFormFieldNumbersOnly(this.title, this.helper, this.required, this.validationText, this.submission, this.initial, this.controller, this.onChanged, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: TextFormField(
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: controller,
        autocorrect: false,
        enableSuggestions: false,
        initialValue: initial,
        maxLines: null,
        onChanged: (val) async {
          submission.object = val;
          await LocalDatabase.updateAdaptiveSettings(onChanged, int.parse(val));
        },
        validator: (value) {
          if ((required ?? false) && (value == null || value.isEmpty)) {
            return validationText;
          }
          return null;
        },
        decoration: InputDecoration(
          filled: false,
          helperText: helper,
          helperStyle: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.014),
          contentPadding: EdgeInsets.zero,
          labelText: title,
          labelStyle: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.021),
        ),
        cursorColor: MediaQuery
            .of(context)
            .platformBrightness == Brightness.light ? Colors.black : Colors
            .white,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.021,
          color: MediaQuery
              .of(context)
              .platformBrightness == Brightness.light ? Colors.black : Colors
              .white,
        ),
      ),
    );
  }
}

class BetterTextFormFieldCard extends StatelessWidget {
  final String title;
  final String? helper;
  final bool required;
  final String? validationText;
  final Wrapper? submission;
  final int pos;
  final String? initial;
  final TextEditingController controller;

  const BetterTextFormFieldCard(this.title, this.helper, this.required, this.validationText, this.submission, this.pos, this.initial, this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: TextFormField(
        controller: controller,
        initialValue: initial,
        autocorrect: false,
        enableSuggestions: false,
        onChanged: (val) => submission?.object[pos] = val,
        maxLines: null,
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return validationText;
          }
          return null;
          },
        decoration: InputDecoration(
        filled: false,
        helperText: helper,
        helperStyle: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.014),
        contentPadding: EdgeInsets.zero,
        labelText: title,
        labelStyle: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.021),
        ),
        cursorColor: MediaQuery
            .of(context)
            .platformBrightness == Brightness.light ? Colors.black : Colors
            .white,
        style: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.021,
        color: MediaQuery
            .of(context)
            .platformBrightness == Brightness.light ? Colors.black : Colors
            .white,
      ),
      ),
    );
  }
}

// textform cards
class BetterCardTextForm extends StatelessWidget {
  final String term;
  final String def;
  final int position;
  final Wrapper? termStorage;
  final Wrapper? defStorage;
  final bool shown;
  final String? initialTerm;
  final String? initialDef;
  final TextEditingController controllerTerm;
  final TextEditingController controllerDef;

  const BetterCardTextForm(this.term, this.def, this.position, this.termStorage, this.defStorage, this.shown, this.initialTerm, this.initialDef, this.controllerTerm, this.controllerDef, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: shown ? null : 0,
      heightFactor: shown ? null : 0,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: SizedBox(
          // height: 200,
          width: shown ? MediaQuery.of(context).size.width * 0.95 : 0,
          child: Column(
            children: <Widget>[
              ListTile(
                title: shown ? BetterTextFormFieldCard(term, null, false, null, termStorage, position, initialTerm, controllerTerm) : null,
                subtitle: shown ? BetterTextFormFieldCard(def, null, false, null, defStorage, position, initialDef, controllerDef) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardSet {
  int position;
  String title;
  String desc;
  IconData icon;
  List<dynamic> terms;
  List<dynamic> defs;

  CardSet(this.position, this.title, this.desc, this.icon, this.terms, this.defs);

  @override
  String toString() {
    return 'CardSet{id: $position, title: $title, desc: $desc, terms: $terms, defs: $defs}';
  }
}

class Wrapper {
  dynamic object;
  Wrapper(this.object);
}