import 'dart:math';

import 'package:card_flash/widgets.dart';
import 'package:flutter/material.dart';
import 'package:lzstring/lzstring.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static late Future<Database> database;

  static Future<void> initializeDB() async {
    WidgetsFlutterBinding.ensureInitialized();

    // adaptiveTermDef:o

    // 0 = def and term
    // 1 = term only
    // 2 = def only
    database = openDatabase(
      join(await getDatabasesPath(), 'sets.db'),
      onCreate: (db, version) async {
        var prefs = await SharedPreferences.getInstance();
        await db.execute(
          'CREATE TABLE folders('
          'folderID INTEGER PRIMARY KEY, '
          'timestamp INTEGER, '
          'position INTEGER, '
          'title TEXT, '
          'desc TEXT, '
          'iconCP INTEGER, '
          'iconFF TEXT, '
          'iconFP TEXT'
          ')',
        );
        await db.execute(
          'CREATE TABLE titles('
          'titleID INTEGER PRIMARY KEY, '
          'timestamp INTEGER, '
          'position INTEGER, '
          'title TEXT, '
          'desc TEXT, '
          'iconCP INTEGER, '
          'iconFF TEXT, '
          'iconFP TEXT, '
          'adaptiveTermDef INTEGER, '
          'multipleChoiceEnabled INTEGER, '
          'writingEnabled INTEGER, '
          'multipleChoiceQuestions INTEGER, '
          'writingQuestions INTEGER, '
          'adaptiveRepeat INTEGER, '
          'flashcardShuffle INTEGER, '
          'flashcardTermDef INTEGER, '
          'flashcardAdaptive INTEGER, '
          'folder INTEGER, '
          'FOREIGN KEY(folder) REFERENCES folders(folderID)'
          ')',
        );
        await db.execute(
          'CREATE TABLE cards('
          'cardID INTEGER PRIMARY KEY, '
          'timestamp INTEGER, '
          'position INTEGER, '
          'term TEXT, '
          'def TEXT, '
          'correctInARowTerm INTEGER, '
          'correctInARowDef INTEGER, '
          'correctTotal INTEGER, '
          'incorrectTotal INTEGER, '
          'flashcardAdaptiveLearned INTEGER, '
          'cardTitle INTEGER'
          ')', // , FOREIGN KEY(cardTitle) REFERENCES cards(titleID)
        );
        if (prefs.getBool("firstTime")!) {
          prefs.setBool("firstTime", false);
          insertSet(CardSet(0, "Tutorial", "Click on me!", Icons.info_rounded, ["You can view all the cards in a set here!", "You can learn through Flashcard or Adaptive!", "Click on the QR to generate a QR code that you can share with friends!", "Click the edit button in the top right to edit the set!"], ["You can swipe to view more cards!", "Click on the buttons below to check it out!", "", "Make sure to press the green checkmark to save your changes!"]));
          insertSet(CardSet(1, "Click on the + in the top right to add a folder!", "", Icons.info_rounded, [], []));
          insertSet(CardSet(2, "Swipe left on a set to delete or move it!", "", Icons.info_rounded, [], []));
          insertSet(CardSet(3, "Long press on a set to move it!", "", Icons.info_rounded, [], []));
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion == 1) {
          await db.execute('ALTER TABLE titles ADD adaptiveRepeat INTEGER');
          await db.execute('UPDATE titles SET adaptiveRepeat = ?', [7]);
          oldVersion = 2;
        }
        if (oldVersion == 2) {
          await db.execute(
            'CREATE TABLE folders('
            'folderID INTEGER PRIMARY KEY, '
            'timestamp INTEGER, '
            'position INTEGER, '
            'title TEXT, '
            'desc TEXT, '
            'iconCP INTEGER, '
            'iconFF TEXT, '
            'iconFP TEXT'
            ')',
          );
          await db.execute('ALTER TABLE titles ADD folder INTEGER');
          await db.execute('UPDATE titles SET folder = ?', [-1]);
          await db.execute('ALTER TABLE titles ADD flashcardAdaptive INTEGER');
          await db.execute('UPDATE titles SET flashcardAdaptive = ?', [1]);
          await db.execute('ALTER TABLE cards ADD flashcardAdaptiveLearned INTEGER');
          await db.execute('UPDATE cards SET flashcardAdaptiveLearned = ?', [0]);
        }
      },
      version: 3,
    );

    // (await database).rawQuery('ALTER TABLE cards ADD smartFlashcard INTEGER');
    // databaseFactory.deleteDatabase("sets.db");
  }

  static Future<dynamic> insertSet(CardSet set) async {
    final db = await database;
    int time;
    late int titleID;

    await db.transaction((txn) async {
      time = DateTime.now().millisecondsSinceEpoch;
      await txn.rawInsert(
          'INSERT INTO titles(timestamp, position, title, desc, iconCP, iconFF, iconFP, adaptiveTermDef, multipleChoiceEnabled, writingEnabled, multipleChoiceQuestions, writingQuestions, flashcardShuffle, flashcardTermDef, adaptiveRepeat, folder, flashcardAdaptive) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            time,
            set.position,
            set.title,
            set.desc,
            set.icon.codePoint,
            set.icon.fontFamily,
            set.icon.fontPackage,
            0,
            1,
            1,
            1,
            1,
            1,
            0,
            7,
            -1,
            1
          ]);
      dynamic records = await txn
          .rawQuery('SELECT titleID FROM titles WHERE timestamp = ?', [time]);
      titleID = records.first['titleID'];
      for (int i = 0; i < set.terms.length; i++) {
        time = DateTime.now().millisecondsSinceEpoch;
        await txn.rawInsert(
            'INSERT INTO cards(timestamp, position, term, def, correctInARowTerm, correctInARowDef, correctTotal, incorrectTotal, cardTitle, flashcardAdaptiveLearned) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [time, i, set.terms[i], set.defs[i], 0, 0, 0, 0, titleID, 0]);
      }
    });
    return titleID;
  }
  
  static Future<void> insertFolder(Folder folder) async {
    final db = await database;
    int time;

    await db.transaction((txn) async {
      time = DateTime.now().millisecondsSinceEpoch;
      await txn.rawInsert(
          'INSERT INTO folders(timestamp, position, title, desc, iconCP, iconFF, iconFP) VALUES(?, ?, ?, ?, ?, ?, ?)',
          [
            time,
            folder.position,
            folder.title,
            folder.desc,
            folder.icon.codePoint,
            folder.icon.fontFamily,
            folder.icon.fontPackage
          ]);
    });
  }

  /// false = exist
  ///
  /// true = not exist
  static Future<dynamic> checkInterSubFolderExists() async {
    final db = await database;

    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM folders WHERE title = ?', ["InterSub"])) == 0;
  }

  static Future<dynamic> getInterSubFolderPos() async {
    final db = await database;

    return (await db.rawQuery('SELECT position FROM folders WHERE title = ?', ["InterSub"]))[0]['position'];
  }

  static Future<dynamic> getFolders() async {
    final db = await database;

    if (Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM folders')) == 0) {
      return null;
    }
    return await db.rawQuery('SELECT * FROM folders ORDER BY position');
  }

  static Future<dynamic> getFoldersNum() async {
    final db = await database;

    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM folders'));
  }

  static Future<dynamic> getFolderID(int position) async {
    final db = await database;

    if (Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM folders')) ==
        0) {
      return null;
    }
    return (await db.rawQuery(
        'SELECT folderID FROM folders WHERE position = ?', [position]))[0]['folderID'];
  }

  static Future<dynamic> getFolderPosition(int id) async {
    final db = await database;

    if (Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM folders')) ==
        0) {
      return null;
    }
    return await db.rawQuery(
        'SELECT position FROM folders WHERE folderID = ?', [id]);
  }

  static Future<dynamic> getHomeData() async {
    final db = await database;
    var val = [];

    if (Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM folders')) !=
        0) {
      val += await db.rawQuery('SELECT * FROM folders ORDER BY position');
    }
    if (Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM titles')) !=
        0) {
      val += await db.rawQuery(
          'SELECT * FROM titles WHERE folder = ? ORDER BY position', [-1]);
    }
    return val.isEmpty ? null : val;
  }

  static Future<dynamic> getTitlesInFolder() async {
    final db = await database;
    final folderID =
        (await SharedPreferences.getInstance()).getInt('currentFolderID');

    if (Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM titles WHERE folder = ?', [folderID])) ==
        0) {
      return null;
    }
    return await db.rawQuery(
        'SELECT * FROM titles WHERE folder = ? ORDER BY position', [folderID]);
  }

  static Future<dynamic> getNextPositionSetInFolder(int folderID) async {
    final db = await database;
    if (Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM titles WHERE folder = ?', [folderID])) ==
        0) {
      return 0;
    } else {
      return (await db.rawQuery('SELECT MIN(position) + 1 FROM titles WHERE folder = ? AND position + 1 NOT IN (SELECT position FROM titles WHERE folder = ?)', [folderID, folderID])).first['MIN(position) + 1'];
    }
  }

  static Future<dynamic> getNextPositionSet() async {
    final db = await database;
    if (Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM titles WHERE folder = -1')) ==
        0) {
      return 0;
    } else {
      return (await db.rawQuery(
              'SELECT MIN(position) + 1 FROM titles WHERE position + 1 NOT IN (SELECT position FROM titles) AND folder = -1'))
          .first['MIN(position) + 1'];
    }
  }

  static Future<dynamic> getNextPositionFolder() async {
    final db = await database;
    if (Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM folders')) ==
        0) {
      return 0;
    } else {
      return (await db.rawQuery(
              'SELECT MIN(position) + 1 FROM folders WHERE position + 1 NOT IN (SELECT position FROM folders)'))
          .first['MIN(position) + 1'];
    }
  }

  static Future<dynamic> getSet() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    if ((Sqflite.firstIntValue(await db.rawQuery(
                'SELECT COUNT(*) FROM cards WHERE cardTitle = ?',
                [prefs.getInt("currentTitleID")]))! + Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles WHERE titleID = ?', [prefs.getInt("currentTitleID")]))!) == 0) {
      return null;
    }
    return (await db.rawQuery('SELECT * FROM titles WHERE titleID = ?',
            [prefs.getInt("currentTitleID")])) +
        (await db.rawQuery(
            'SELECT * FROM cards WHERE cardTitle = ? ORDER BY position',
            [prefs.getInt("currentTitleID")]));
  }

  static Future<dynamic> getSetWithTitleID(int titleID) async {
    final db = await database;

    if ((Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM cards WHERE cardTitle = ?',
        [titleID]))! + Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles WHERE titleID = ?', [titleID]))!) == 0) {
      return null;
    }
    return (await db.rawQuery('SELECT * FROM titles WHERE titleID = ?',
        [titleID])) +
        (await db.rawQuery(
            'SELECT * FROM cards WHERE cardTitle = ? ORDER BY position',
            [titleID]));
  }

  static Future<dynamic> getNotLearnedFlashcardAdaptive() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    if ((Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM cards WHERE cardTitle = ?',
        [prefs.getInt("currentTitleID")]))! + Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles WHERE titleID = ?', [prefs.getInt("currentTitleID")]))!) == 0) {
      return null;
    }
    return (await db.rawQuery('SELECT * FROM titles WHERE titleID = ?',
        [prefs.getInt("currentTitleID")]) + await db.rawQuery(
            'SELECT * FROM cards WHERE cardTitle = ? AND flashcardAdaptiveLearned = ? ORDER BY position',
            [prefs.getInt("currentTitleID"), 0]));
  }

  /// return a string with set data compressed in to UTF16
  static Future<dynamic> getString() async {
    final prefs = await SharedPreferences.getInstance();

    final db = await database;

    if ((Sqflite.firstIntValue(await db.rawQuery(
                'SELECT COUNT(*) FROM cards WHERE cardTitle = ?',
                [prefs.getInt("currentTitleID")]))! +
            Sqflite.firstIntValue(await db.rawQuery(
                'SELECT COUNT(*) FROM titles WHERE titleID = ?',
                [prefs.getInt("currentTitleID")]))!) ==
        0) {
      return null;
    }
    final set = (await db.rawQuery(
            'SELECT title, desc, iconCP, iconFF, iconFP FROM titles WHERE titleID = ?',
            [
              prefs.getInt("currentTitleID")
            ])) +
        (await db.rawQuery(
            'SELECT term, def FROM cards WHERE cardTitle = ? ORDER BY position',
            [prefs.getInt("currentTitleID")]));
    String data = "";
    for (int i = 0; i < set.length; i++) {
      for (var value in set[i].values) {
        data += "$value§¶";
      }
    }
    final betterString = LZString.compressToUTF16Sync(data);
    return betterString;
  }

  static Future<void> updateSetWithID(CardSet set, int titleID) async {
    final db = await database;
    final oldTermCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM cards WHERE cardTitle = ?',
        [titleID]));
    // titles: (timestamp, position, title, desc, iconCP, iconFF, iconFP)
    //[time, set.position, set.title, set.desc, set.icon.codePoint, set.icon.fontFamily, set.icon.fontPackage]
    // cards(timestamp, position, term, def, correctInARow, cardTitle)
    // [time, i, set.terms[i], set.defs[i], 0, titleID]
    int time = DateTime.now().millisecondsSinceEpoch;
    await db.rawQuery(
        'UPDATE titles SET timestamp = ?, position = ?, title = ?, desc = ?, iconCP = ?, iconFF = ?, iconFP = ? WHERE titleID = ?',
        [
          time,
          set.position,
          set.title,
          set.desc,
          set.icon.codePoint,
          set.icon.fontFamily ?? "",
          set.icon.fontPackage ?? "",
          titleID
        ]);
    int firstCount = min(set.terms.length, oldTermCount!);
    for (int i = 0; i < firstCount; i++) {
      time = DateTime.now().millisecondsSinceEpoch;
      await db.rawQuery(
          'UPDATE cards SET timestamp = ?, term = ?, def = ? WHERE cardTitle = ? AND position = ?',
          [time, set.terms[i], set.defs[i], titleID, i]);
    }
    if (set.terms.length < oldTermCount) {
      for (int i = set.terms.length; i < oldTermCount; i++) {
        await db.rawQuery(
            'DELETE FROM cards WHERE cardTitle = ? AND position = ?',
            [titleID, i]);
      }
    }
    if (set.terms.length > oldTermCount) {
      for (int i = oldTermCount; i < set.terms.length; i++) {
        time = DateTime.now().millisecondsSinceEpoch;
        await db.rawQuery(
            'INSERT INTO cards(timestamp, position, term, def, correctInARowTerm, correctInARowDef, correctTotal, incorrectTotal, cardTitle, flashcardAdaptiveLearned) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              time,
              i,
              set.terms[i],
              set.defs[i],
              0,
              0,
              0,
              0,
              titleID,
              0
            ]);
      }
    }
  }

  static Future<void> updateSet(CardSet set) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();
    final oldTermCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM cards WHERE cardTitle = ?',
        [prefs.getInt("currentTitleID")]));
    // titles: (timestamp, position, title, desc, iconCP, iconFF, iconFP)
    //[time, set.position, set.title, set.desc, set.icon.codePoint, set.icon.fontFamily, set.icon.fontPackage]
    // cards(timestamp, position, term, def, correctInARow, cardTitle)
    // [time, i, set.terms[i], set.defs[i], 0, titleID]
    int time = DateTime.now().millisecondsSinceEpoch;
    await db.rawQuery(
        'UPDATE titles SET timestamp = ?, position = ?, title = ?, desc = ?, iconCP = ?, iconFF = ?, iconFP = ? WHERE titleID = ?',
        [
          time,
          set.position,
          set.title,
          set.desc,
          set.icon.codePoint,
          set.icon.fontFamily ?? "",
          set.icon.fontPackage ?? "",
          prefs.getInt('currentTitleID')
        ]);
    int firstCount = min(set.terms.length, oldTermCount!);
    for (int i = 0; i < firstCount; i++) {
      time = DateTime.now().millisecondsSinceEpoch;
      await db.rawQuery(
          'UPDATE cards SET timestamp = ?, term = ?, def = ? WHERE cardTitle = ? AND position = ?',
          [time, set.terms[i], set.defs[i], prefs.getInt('currentTitleID'), i]);
    }
    if (set.terms.length < oldTermCount) {
      for (int i = set.terms.length; i < oldTermCount; i++) {
        await db.rawQuery(
            'DELETE FROM cards WHERE cardTitle = ? AND position = ?',
            [prefs.getInt('currentTitleID'), i]);
      }
    }
    if (set.terms.length > oldTermCount) {
      for (int i = oldTermCount; i < set.terms.length; i++) {
        time = DateTime.now().millisecondsSinceEpoch;
        await db.rawQuery(
            'INSERT INTO cards(timestamp, position, term, def, correctInARowTerm, correctInARowDef, correctTotal, incorrectTotal, cardTitle, flashcardAdaptiveLearned) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              time,
              i,
              set.terms[i],
              set.defs[i],
              0,
              0,
              0,
              0,
              prefs.getInt('currentTitleID'),
              0
            ]);
      }
    }
  }

  static Future<void> updateSetPosition(
      int oldPosition, int newPosition, int titleID) async {
    final db = await database;
    final oldTitles =
        await db.rawQuery('SELECT * FROM titles ORDER BY position');

    if (newPosition < oldPosition) {
      int time = DateTime.now().millisecondsSinceEpoch;
      db.rawQuery(
          'UPDATE titles SET timestamp = ?, position = ? WHERE titleID = ?',
          [time, newPosition, titleID]);
      for (int i = newPosition; i < oldPosition; i++) {
        int time = DateTime.now().millisecondsSinceEpoch;
        db.rawQuery(
            'UPDATE titles SET timestamp = ?, position = ? WHERE titleID = ?',
            [time, i + 1, oldTitles[i]['titleID']]);
      }
    }
    else if (newPosition > oldPosition) {
      int time = DateTime.now().millisecondsSinceEpoch;
      db.rawQuery(
          'UPDATE titles SET timestamp = ?, position = ? WHERE titleID = ?',
          [time, newPosition - 1, titleID]);
      for (int i = oldPosition + 1; i < newPosition; i++) {
        int time = DateTime.now().millisecondsSinceEpoch;
        db.rawQuery(
            'UPDATE titles SET timestamp = ?, position = ? WHERE titleID = ?',
            [time, i - 1, oldTitles[i]['titleID']]);
      }
    }
  }

  static Future<void> updateSetFolder(int folderID, int titleID) async {
    final db = await database;

    int time = DateTime.now().millisecondsSinceEpoch;
    await db.rawQuery('UPDATE titles SET timestamp = ?, folder = ? WHERE titleID = ?',
        [time, folderID, titleID]);
  }

  static Future<void> updateFolderPosition(
      int oldPosition, int newPosition, int folderID) async {
    final db = await database;
    final oldFolders =
        await db.rawQuery('SELECT * FROM folders ORDER BY position');

    if (newPosition < oldPosition) {
      int time = DateTime.now().millisecondsSinceEpoch;
      db.rawQuery(
          'UPDATE folders SET timestamp = ?, position = ? WHERE folderID = ?',
          [time, newPosition, folderID]);
      for (int i = newPosition; i < oldPosition; i++) {
        int time = DateTime.now().millisecondsSinceEpoch;
        db.rawQuery(
            'UPDATE folders SET timestamp = ?, position = ? WHERE folderID = ?',
            [time, i + 1, oldFolders[i]['folderID']]);
      }
    } else if (newPosition > oldPosition) {
      int time = DateTime.now().millisecondsSinceEpoch;
      db.rawQuery(
          'UPDATE folders SET timestamp = ?, position = ? WHERE folderID = ?',
          [time, newPosition, folderID]);
      for (int i = oldPosition + 1; i < newPosition; i++) {
        int time = DateTime.now().millisecondsSinceEpoch;
        db.rawQuery(
            'UPDATE folders SET timestamp = ?, position = ? WHERE folderID = ?',
            [time, i - 1, oldFolders[i]['folderID']]);
      }
    }
  }

  /// positive for correct
  ///
  /// negative for incorrect
  static Future<void> updateCorrectIncorrect(
      int position, int correctIncorrect) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    if (correctIncorrect > 0) {
      final Object? num = (await db.rawQuery(
          'SELECT correctTotal FROM cards WHERE cardTitle = ? AND position = ?',
          [prefs.getInt('currentTitleID'), position]))[0]['correctTotal'];
      await db.rawQuery(
          'UPDATE cards SET correctTotal = ? WHERE cardTitle = ? AND position = ?',
          [
            int.parse(num!.toString()) + correctIncorrect,
            prefs.getInt('currentTitleID'),
            position
          ]);
    }
    if (correctIncorrect < 0) {
      final num = (await db.rawQuery(
          'SELECT incorrectTotal FROM cards WHERE cardTitle = ? AND position = ?',
          [prefs.getInt('currentTitleID'), position]))[0]['incorrectTotal'];
      await db.rawQuery(
          'UPDATE cards SET incorrectTotal = ? WHERE cardTitle = ? AND position = ?',
          [
            int.parse(num!.toString()) + correctIncorrect.abs(),
            prefs.getInt('currentTitleID'),
            position
          ]);
    }
  }

  static Future<void> setCorrectIncorrect(
      int position, int correctIncorrect) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    if (correctIncorrect > 0) {
      await db.rawQuery(
          'UPDATE cards SET correctTotal = ? WHERE cardTitle = ? AND position = ?',
          [correctIncorrect, prefs.getInt('currentTitleID'), position]);
    }
    if (correctIncorrect < 0) {
      await db.rawQuery(
          'UPDATE cards SET incorrectTotal = ? WHERE cardTitle = ? AND position = ?',
          [correctIncorrect.abs(), prefs.getInt('currentTitleID'), position]);
    }
  }

  static Future<void> resetCorrectIncorrect(int position) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    await db.rawQuery(
        'UPDATE cards SET correctTotal = ? WHERE cardTitle = ? AND position = ?',
        [0, prefs.getInt('currentTitleID'), position]);
    await db.rawQuery(
        'UPDATE cards SET incorrectTotal = ? WHERE cardTitle = ? AND position = ?',
        [0, prefs.getInt('currentTitleID'), position]);
  }

  static Future<void> setCorrectInARow(
      int position, int correctInARow, int termDef) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    if (termDef == 2) {
      await db.rawQuery(
          'UPDATE cards SET correctInARowTerm = ? WHERE cardTitle = ? AND position = ?',
          [correctInARow, prefs.getInt('currentTitleID'), position]);
    } else if (termDef == 1) {
      await db.rawQuery(
          'UPDATE cards SET correctInARowDef = ? WHERE cardTitle = ? AND position = ?',
          [correctInARow, prefs.getInt('currentTitleID'), position]);
    }
  }

  /// Increments the correctInARow by 1
  ///
  /// term = 0
  ///
  /// def = 1
  static Future<void> increaseCorrectInARow(int position, int termDef) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    if (termDef == 2) {
      final correct = (await db.rawQuery(
          'SELECT correctInARowTerm FROM cards WHERE cardTitle = ? AND position = ?',
          [prefs.getInt('currentTitleID'), position]))[0]['correctInARowTerm'];
      await db.rawQuery(
          'UPDATE cards SET correctInARowTerm = ? WHERE cardTitle = ? AND position = ?',
          [
            int.parse(correct!.toString()) + 1,
            prefs.getInt('currentTitleID'),
            position
          ]);
    } else if (termDef == 1) {
      final correct = (await db.rawQuery(
          'SELECT correctInARowDef FROM cards WHERE cardTitle = ? AND position = ?',
          [prefs.getInt('currentTitleID'), position]))[0]['correctInARowDef'];
      await db.rawQuery(
          'UPDATE cards SET correctInARowDef = ? WHERE cardTitle = ? AND position = ?',
          [
            int.parse(correct!.toString()) + 1,
            prefs.getInt('currentTitleID'),
            position
          ]);
    }
  }

  static Future<void> resetCorrectInARow(int position, int termDef) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    if (termDef == 2) {
      await db.rawQuery(
          'UPDATE cards SET correctInARowTerm = ? WHERE cardTitle = ? AND position = ?',
          [0, prefs.getInt('currentTitleID'), position]);
    } else if (termDef == 1) {
      await db.rawQuery(
          'UPDATE cards SET correctInARowDef = ? WHERE cardTitle = ? AND position = ?',
          [0, prefs.getInt('currentTitleID'), position]);
    }
  }

  static Future<void> updateFlashcardAdaptiveLearned(int cardID, int adaptiveLearned) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    await db.rawQuery(
        'UPDATE cards SET flashcardAdaptiveLearned = ? WHERE cardTitle = ? AND cardID = ?',
        [adaptiveLearned, prefs.getInt('currentTitleID'), cardID]);
  }

  static Future<void> resetFlashcardAdaptiveLearned() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    await db.rawQuery(
        'UPDATE cards SET flashcardAdaptiveLearned = ? WHERE cardTitle = ?',
        [0, prefs.getInt('currentTitleID')]);
  }

  static Future<void> resetAdaptive() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    await db.rawQuery(
        'UPDATE cards SET correctInARowTerm = ? WHERE cardTitle = ?',
        [0, prefs.getInt('currentTitleID')]);
    await db.rawQuery(
        'UPDATE cards SET correctInARowDef = ? WHERE cardTitle = ?',
        [0, prefs.getInt('currentTitleID')]);
  }

  static Future<void> updateAdaptiveSettings(int selection, int data) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    switch (selection) {
      case 1:
        await db.rawQuery(
            'UPDATE titles SET adaptiveTermDef = ? WHERE titleID = ?',
            [data, prefs.getInt('currentTitleID')]);
        break;
      case 2:
        await db.rawQuery(
            'UPDATE titles SET multipleChoiceEnabled = ? WHERE titleID = ?',
            [data, prefs.getInt('currentTitleID')]);
        break;
      case 3:
        await db.rawQuery(
            'UPDATE titles SET writingEnabled = ? WHERE titleID = ?',
            [data, prefs.getInt('currentTitleID')]);
        break;
      case 4:
        await db.rawQuery(
            'UPDATE titles SET multipleChoiceQuestions = ? WHERE titleID = ?',
            [data, prefs.getInt('currentTitleID')]);
        break;
      case 5:
        await db.rawQuery(
            'UPDATE titles SET writingQuestions = ? WHERE titleID = ?',
            [data, prefs.getInt('currentTitleID')]);
        break;
      case 6:
        await db.rawQuery(
            'UPDATE titles SET adaptiveRepeat = ? WHERE titleID = ?',
            [data, prefs.getInt('currentTitleID')]);
        break;
    }
  }

  static Future<void> updateFlashcardShuffle(int shuffle) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    await db.rawQuery(
        'UPDATE titles SET flashcardShuffle = ? WHERE titleID = ?',
        [shuffle, prefs.getInt('currentTitleID')]);
  }

  static Future<void> updateFlashcardTermDef(int termDef) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    await db.rawQuery(
        'UPDATE titles SET flashcardTermDef = ? WHERE titleID = ?',
        [termDef, prefs.getInt('currentTitleID')]);
  }

  static Future<void> updateFlashcardAdaptive(int adaptive) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    await db.rawQuery(
        'UPDATE titles SET flashcardAdaptive = ? WHERE titleID = ?',
        [adaptive, prefs.getInt('currentTitleID')]);
  }

  static Future<void> deleteFolder(folderID) async {
    final db = await database;

    // titles: (timestamp, position, title, desc, iconCP, iconFF, iconFP)
    //[time, set.position, set.title, set.desc, set.icon.codePoint, set.icon.fontFamily, set.icon.fontPackage]
    // cards(timestamp, position, term, def, correctInARow, cardTitle)
    // [time, i, set.terms[i], set.defs[i], 0, titleID]
    await db.rawQuery('DELETE FROM folders WHERE folderID = ?', [folderID]);
    await db.rawQuery(
        'UPDATE titles SET folder = ? WHERE folder = ?', [-1, folderID]);
  }

  static Future<void> deleteSet(titleID) async {
    final db = await database;

    // titles: (timestamp, position, title, desc, iconCP, iconFF, iconFP)
    //[time, set.position, set.title, set.desc, set.icon.codePoint, set.icon.fontFamily, set.icon.fontPackage]
    // cards(timestamp, position, term, def, correctInARow, cardTitle)
    // [time, i, set.terms[i], set.defs[i], 0, titleID]
    await db.rawQuery('DELETE FROM titles WHERE titleID = ?', [titleID]);
    await db.rawQuery('DELETE FROM cards WHERE cardTitle = ?', [titleID]);
  }

  static Future<void> clearTables() async {
    final db = await database;

    await db.rawQuery('DELETE FROM cards');
    await db.rawQuery('DELETE FROM titles');
    await db.rawQuery('DELETE FROM folders');
    await db.rawQuery('VACUUM');
  }
}