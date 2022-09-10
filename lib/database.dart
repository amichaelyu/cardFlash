import 'dart:math';

import 'package:card_flash/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class Database {
  static late final database;

  static Future<void> initializeDB() async {
    WidgetsFlutterBinding.ensureInitialized();

    // adaptiveTermDef:
    // 0 = def and term
    // 1 = term only
    // 2 = def only
    database = openDatabase(
      join(await getDatabasesPath(), 'sets.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE titles(titleID INTEGER PRIMARY KEY, timestamp INTEGER, position INTEGER, title TEXT, desc TEXT, iconCP INTEGER, iconFF TEXT, iconFP TEXT, adaptiveTermDef INTEGER, multipleChoiceEnabled INTEGER, writingEnabled INTEGER, multipleChoiceQuestions INTEGER, writingQuestions INTEGER)',
        );
        return await db.execute(
          'CREATE TABLE cards(cardID INTEGER PRIMARY KEY, timestamp INTEGER, position INTEGER, term TEXT, def TEXT, correctInARowTerm INTEGER, correctInARowDef INTEGER, correctTotal INTEGER, incorrectTotal INTEGER, cardTitle INTEGER)', // , FOREIGN KEY(cardTitle) REFERENCES cards(titleID)
        );
      },
      version: 1,
    );

    // (await database).rawQuery('ALTER TABLE cards ADD smartFlashcard INTEGER');
    // databaseFactory.deleteDatabase("sets.db"); // delete db
  }

  static Future<dynamic> insertSet(CardSet set) async {
    final db = await database;
    int time;
    late int titleID;

    await db.transaction((txn) async {
      time = DateTime.now().millisecondsSinceEpoch;
      await txn.rawInsert(
          'INSERT INTO titles(timestamp, position, title, desc, iconCP, iconFF, iconFP, adaptiveTermDef, multipleChoiceEnabled, writingEnabled, multipleChoiceQuestions, writingQuestions) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [time, set.position, set.title, set.desc, set.icon.codePoint, set.icon.fontFamily, set.icon.fontPackage, 0, 1, 1, 2, 1]
      );
      dynamic records = await txn.rawQuery('SELECT titleID FROM titles WHERE timestamp = ?', [time]);
      titleID = records.first['titleID'];
      for (int i = 0; i < set.terms.length; i++) {
        time = DateTime.now().millisecondsSinceEpoch;
        await txn.rawInsert(
            'INSERT INTO cards(timestamp, position, term, def, correctInARowTerm, correctInARowDef, correctTotal, incorrectTotal, cardTitle) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [time, i, set.terms[i], set.defs[i], 0, 0, 0, 0, titleID]
        );
      }
    });
    return titleID;
  }

  static Stream<dynamic> getTitles() async* {
    final db = await database;
    var lastQuery;
    var lastQueryNum;

    while (true) {
      if (lastQuery == await db.rawQuery('SELECT * FROM titles ORDER BY position') || lastQueryNum == Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles'))) continue;
      lastQuery = await db.rawQuery('SELECT * FROM titles ORDER BY position');
      if (Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles')) == 0) {
        lastQueryNum = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles'));
        yield null;
      }
      else {
        yield await lastQuery;
      }
    }
  }

  static Future<dynamic> getNextPosition() async {
    final db = await database;
    if (Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles')) == 0) {
      return 0;
    }
    else {
      return (await db.rawQuery('SELECT MIN(position) + 1 FROM titles WHERE position + 1 NOT IN (SELECT position FROM titles)')).first['MIN(position) + 1'];
    }
  }

  static Stream<dynamic> getSetStream() async* {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();
    var lastQuery;
    var lastQueryNum;

    while (true) {
      if (prefs.getInt("currentTitleID") != -1) {
        if ((lastQuery == (await db.rawQuery('SELECT * FROM titles WHERE titleID = ?', [prefs.getInt("currentTitleID")]) + await db.rawQuery('SELECT * FROM cards WHERE cardTitle = ? ORDER BY position', [prefs.getInt("currentTitleID")]))) && (lastQueryNum != (Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cards WHERE cardTitle = ?', [prefs.getInt("currentTitleID")]))! + Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles where titleID = ?', [prefs.getInt("currentTitleID")]))!))) {
          continue;
        }
        lastQuery = ((await db.rawQuery('SELECT * FROM titles WHERE titleID = ?', [prefs.getInt("currentTitleID")])) + (await db.rawQuery('SELECT * FROM cards WHERE cardTitle = ? ORDER BY position', [prefs.getInt("currentTitleID")])));
        if ((Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cards WHERE cardTitle = ?', [prefs.getInt("currentTitleID")]))! + Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles WHERE titleID = ?', [prefs.getInt("currentTitleID")]))!) == 0) {lastQueryNum = (Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cards WHERE cardTitle = ?', [prefs.getInt("currentTitleID")]))! + Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles WHERE titleID = ?', [prefs.getInt("currentTitleID")]))!);
          yield null;
        }
        yield await lastQuery;
      }
    }
  }

  static Future<dynamic> getSetFuture() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    if ((Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cards WHERE cardTitle = ?', [prefs.getInt("currentTitleID")]))! + Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles WHERE titleID = ?', [prefs.getInt("currentTitleID")]))!) == 0) {
        return null;
    }
    return (await db.rawQuery('SELECT * FROM titles WHERE titleID = ?', [prefs.getInt("currentTitleID")])) + (await db.rawQuery('SELECT * FROM cards WHERE cardTitle = ? ORDER BY position', [prefs.getInt("currentTitleID")]));
  }

  static Future<void> updateSet(CardSet set) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();
    final oldTermCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cards WHERE cardTitle = ?', [prefs.getInt("currentTitleID")]));
    // titles: (timestamp, position, title, desc, iconCP, iconFF, iconFP)
    //[time, set.position, set.title, set.desc, set.icon.codePoint, set.icon.fontFamily, set.icon.fontPackage]
    // cards(timestamp, position, term, def, correctInARow, cardTitle)
    // [time, i, set.terms[i], set.defs[i], 0, titleID]
    int time = DateTime.now().millisecondsSinceEpoch;
    await db.rawQuery(
        'UPDATE titles SET timestamp = ?, position = ?, title = ?, desc = ?, iconCP = ?, iconFF = ?, iconFP = ? WHERE titleID = ?',
        [time, set.position, set.title, set.desc, set.icon.codePoint, set.icon.fontFamily, set.icon.fontPackage, prefs.getInt('currentTitleID')]);
    int firstCount = min(set.terms.length , oldTermCount!);
    for (int i = 0; i < firstCount; i++) {
      time = DateTime
          .now()
          .millisecondsSinceEpoch;
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
            'INSERT INTO cards(timestamp, position, term, def, correctInARowTerm, correctInARowDef, correctTotal, incorrectTotal, cardTitle) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [time, i, set.terms[i], set.defs[i], 0, 0, 0, 0, prefs.getInt('currentTitleID')]
        );
      }
    }
  }

  /// positive for correct
  /// negative for incorrect
  static Future<void> updateCorrectIncorrect(int position, int correctIncorrect) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    if (correctIncorrect > 0) {
      final num = (await db.rawQuery('SELECT correctTotal FROM cards WHERE cardTitle = ? AND position = ?', [prefs.getInt('currentTitleID'), position]))[0]['correctTotal'];
      await db.rawQuery(
          'UPDATE cards SET correctTotal = ? WHERE cardTitle = ? AND position = ?',
          [num + correctIncorrect, prefs.getInt('currentTitleID'), position]);
    }
    if (correctIncorrect < 0) {
      final num = (await db.rawQuery('SELECT incorrectTotal FROM cards WHERE cardTitle = ? AND position = ?', [prefs.getInt('currentTitleID'), position]))[0]['incorrectTotal'];
      await db.rawQuery(
          'UPDATE cards SET incorrectTotal = ? WHERE cardTitle = ? AND position = ?',
          [num + correctIncorrect.abs(), prefs.getInt('currentTitleID'), position]);
    }
  }

  static Future<void> setCorrectIncorrect(int position, int correctIncorrect) async {
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

  static Future<void> setCorrectInARow(int position, int correctInARow, int termDef) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    if (termDef == 2) {
      await db.rawQuery(
          'UPDATE cards SET correctInARowTerm = ? WHERE cardTitle = ? AND position = ?',
          [correctInARow, prefs.getInt('currentTitleID'), position]);
    }
    else if (termDef == 1) {
      await db.rawQuery(
          'UPDATE cards SET correctInARowDef = ? WHERE cardTitle = ? AND position = ?',
          [correctInARow, prefs.getInt('currentTitleID'), position]);
    }
  }

  /// Increments the correctInARow by 1
  /// term = 0
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
          [correct + 1, prefs.getInt('currentTitleID'), position]);
    }
    else if (termDef == 1) {
      final correct = (await db.rawQuery(
          'SELECT correctInARowDef FROM cards WHERE cardTitle = ? AND position = ?',
          [prefs.getInt('currentTitleID'), position]))[0]['correctInARowDef'];
      await db.rawQuery(
          'UPDATE cards SET correctInARowDef = ? WHERE cardTitle = ? AND position = ?',
          [correct + 1, prefs.getInt('currentTitleID'), position]);
    }
  }

  static Future<void> resetCorrectInARow(int position, int termDef) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    if (termDef == 2) {
      await db.rawQuery(
          'UPDATE cards SET correctInARowTerm = ? WHERE cardTitle = ? AND position = ?',
          [0, prefs.getInt('currentTitleID'), position]);
    }
    else if (termDef == 1) {
      await db.rawQuery(
          'UPDATE cards SET correctInARowDef = ? WHERE cardTitle = ? AND position = ?',
          [0, prefs.getInt('currentTitleID'), position]);
    }
  }

  static Future<void> resetAdaptive() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    await db.rawQuery('UPDATE cards SET correctInARowTerm = ? WHERE cardTitle = ?', [0, prefs.getInt('currentTitleID')]);
    await db.rawQuery('UPDATE cards SET correctInARowDef = ? WHERE cardTitle = ?', [0, prefs.getInt('currentTitleID')]);
  }

  static Future<void> updateAdaptiveSettings(int adaptiveTermDef, int multipleChoiceEnabled, int writingEnabled, int multipleChoiceQuestions, int writingQuestions) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    await db.rawQuery('UPDATE titles SET adaptiveTermDef = ? WHERE titleID = ?', [adaptiveTermDef, prefs.getInt('currentTitleID')]);
    await db.rawQuery('UPDATE titles SET multipleChoiceEnabled = ? WHERE titleID = ?', [multipleChoiceEnabled, prefs.getInt('currentTitleID')]);
    await db.rawQuery('UPDATE titles SET writingEnabled = ? WHERE titleID = ?', [writingEnabled, prefs.getInt('currentTitleID')]);
    await db.rawQuery('UPDATE titles SET multipleChoiceQuestions = ? WHERE titleID = ?', [multipleChoiceQuestions, prefs.getInt('currentTitleID')]);
    await db.rawQuery('UPDATE titles SET writingQuestions = ? WHERE titleID = ?', [writingQuestions, prefs.getInt('currentTitleID')]);
  }

  static Future<void> deleteSet(titleID) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

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
    await db.rawQuery('VACUUM');
  }
}