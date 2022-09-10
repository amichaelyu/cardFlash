import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BetterAppBar extends StatelessWidget implements PreferredSizeWidget {
  final title;
  final actions;
  final leading;
  final bottom;

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
          fontSize: 30,
        ),
        iconTheme: IconThemeData(color: MediaQuery.of(context).platformBrightness != Brightness.light ? Colors.white : Colors.black),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold
          ),
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
  final title;
  final desc;
  final icon;
  final nav;
  final navCustom;
  final titleID;

  const BetterCardHome(this.title, this.desc, this.icon, this.titleID, this.nav, this.navCustom, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () async {
            final navigator = Navigator.of(context);
            (await SharedPreferences.getInstance()).setInt("currentTitleID", titleID);
            navigator.pushNamed(nav);
          },
          child: SizedBox(
            width: 370,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(icon),
                  title: Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
                  subtitle: Text(desc),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('STUDY'),
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
  final title;
  final icon;
  final nav;

  const BetterCardSet(this.title, this.icon, this.nav, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Navigator.pushNamed(context, nav);
          },
          child: SizedBox(
            width: 370,

            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(icon),
                  title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                  ),
                  // subtitle: Text(desc),
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
final title;
final desc;
final icon;
final nav;

const BetterCardFlash(this.title, this.desc, this.icon, this.nav, {super.key});

@override
Widget build(BuildContext context) {
  return Center(
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.pushNamed(context, nav);
        },
        child: SizedBox(
          width: 370,

          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(icon),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                // subtitle: Text(desc),
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
  final title;
  final desc;
  final icon;
  final nav;

  const BetterCardAdd(this.title, this.desc, this.icon, this.nav, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Navigator.pushNamed(context, nav);
          },
          child: SizedBox(
            width: 370,

            child: Column(
              children: <Widget>[
                ListTile(
                  leading: icon,
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(desc),
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
  final title;
  final action;
  final color;

  const BetterCardSettings(this.title, this.action, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: color,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: action,
          child: SizedBox(
            width: 300,
            height: 60,
            child: Padding(padding: const EdgeInsets.fromLTRB(0, 16, 0, 0), child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
              ),
            ),
          ),
    );
  }
}

class BetterTextFormField extends StatelessWidget {
  final title;
  final helper;
  final required;
  final validationText;
  final submission;
  final inital;
  final controller;

  const BetterTextFormField(this.title, this.helper, this.required, this.validationText, this.submission, this.inital, this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: TextFormField(
        controller: controller,
        autocorrect: false,
        initialValue: inital,
        maxLines: null,
        onChanged: (val) => submission.object = val,
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return validationText;
          }
          return null;
        },
        decoration: InputDecoration(
          filled: false,
          helperText: helper,
          helperStyle: const TextStyle(fontSize: 12),
          contentPadding: EdgeInsets.zero,
          labelText: title,
          labelStyle: const TextStyle(fontSize: 18),
        ),
        cursorColor: MediaQuery
            .of(context)
            .platformBrightness == Brightness.light ? Colors.black : Colors
            .white,
        style: TextStyle(
          fontSize: 18,
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
  final title;
  final helper;
  final required;
  final validationText;
  final submission;
  final inital;
  final controller;

  const BetterTextFormFieldNumbersOnly(this.title, this.helper, this.required, this.validationText, this.submission, this.inital, this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: TextFormField(
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: controller,
        autocorrect: false,
        initialValue: inital,
        maxLines: null,
        onChanged: (val) => submission.object = val,
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return validationText;
          }
          return null;
        },
        decoration: InputDecoration(
          filled: false,
          helperText: helper,
          helperStyle: const TextStyle(fontSize: 12),
          contentPadding: EdgeInsets.zero,
          labelText: title,
          labelStyle: const TextStyle(fontSize: 18),
        ),
        cursorColor: MediaQuery
            .of(context)
            .platformBrightness == Brightness.light ? Colors.black : Colors
            .white,
        style: TextStyle(
          fontSize: 18,
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
  final title;
  final helper;
  final required;
  final validationText;
  final submission;
  final pos;
  final inital;

  const BetterTextFormFieldCard(this.title, this.helper, this.required, this.validationText, this.submission, this.pos, this.inital, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: TextFormField(
        initialValue: inital,
        autocorrect: false,
        onChanged: (val) => submission.object[pos] = val,
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
        helperStyle: const TextStyle(fontSize: 12),
        contentPadding: EdgeInsets.zero,
        labelText: title,
        labelStyle: const TextStyle(fontSize: 18),
        ),
        cursorColor: MediaQuery
            .of(context)
            .platformBrightness == Brightness.light ? Colors.black : Colors
            .white,
        style: TextStyle(
        fontSize: 18,
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
  final term;
  final def;
  final position;
  final termStorage;
  final defStorage;
  final shown;
  final initalTerm;
  final initalDef;

  const BetterCardTextForm(this.term, this.def, this.position, this.termStorage, this.defStorage, this.shown, this.initalTerm, this.initalDef, {super.key});

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
          width: shown ? 370 : 0,
          child: Column(
            children: <Widget>[
              ListTile(
                title: shown ? BetterTextFormFieldCard(term, null, false, null, termStorage, position, initalTerm) : null,
                subtitle: shown ? BetterTextFormFieldCard(def, null, false, null, defStorage, position, initalDef) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DismissKeyboard extends StatelessWidget {
  final Widget child;

  const DismissKeyboard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: child,
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

class Object {
  dynamic object;
  Object(this.object);
}