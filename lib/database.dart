import 'package:card_flash/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class Database {
  static late final database;

  static Future<void> initializeDB() async {
    WidgetsFlutterBinding.ensureInitialized();

    database = openDatabase(
      join(await getDatabasesPath(), 'sets.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE titles(titleID INTEGER PRIMARY KEY, timestamp INTEGER, position INTEGER, title TEXT, desc TEXT, iconCP INTEGER, iconFF TEXT, iconFP TEXT)',
        );
        return await db.execute(
          'CREATE TABLE cards(cardID INTEGER PRIMARY KEY, timestamp INTEGER, position INTEGER, term TEXT, def TEXT, correctInARow INTEGER, cardTitle INTEGER)', // , FOREIGN KEY(cardTitle) REFERENCES cards(titleID)
        );
      },
      version: 1,
    );

    // databaseFactory.deleteDatabase("sets.db"); // delete db
  }

  static Future<dynamic> insertSet(CardSet set) async {
    final db = await database;
    int time;
    late int titleID;

    await db.transaction((txn) async {
      time = DateTime.now().millisecondsSinceEpoch;
      await txn.rawInsert(
          'INSERT INTO titles(timestamp, position, title, desc, iconCP, iconFF, iconFP) VALUES(?, ?, ?, ?, ?, ?, ?)',
          [time, set.position, set.title, set.desc, set.icon.codePoint, set.icon.fontFamily, set.icon.fontPackage]
      );
      dynamic records = await txn.rawQuery('SELECT titleID FROM titles WHERE timestamp = ?', [time]);
      titleID = records.first['titleID'];
      for (int i = 0; i < set.terms.length; i++) {
        time = DateTime.now().millisecondsSinceEpoch;
        await txn.rawInsert(
            'INSERT INTO cards(timestamp, position, term, def, correctInARow, cardTitle) VALUES(?, ?, ?, ?, ?, ?)',
            [time, i, set.terms[i], set.defs[i], 0, titleID]
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

  static Stream<dynamic> getCards() async* {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();
    var lastQuery;
    var lastQueryNum;

    while (true) {
      if (prefs.getInt("currentTitleID") != -1) {
        if (lastQuery == await db.rawQuery(
            'SELECT * FROM cards WHERE cardTitle = ? ORDER BY position', [prefs.getInt("currentTitleID")]) ||
            lastQueryNum == Sqflite.firstIntValue(
                await db.rawQuery('SELECT COUNT(*) FROM cards'))) continue;
        lastQuery =
        await db.rawQuery('SELECT * FROM cards WHERE cardTitle = ? ORDER BY position', [prefs.getInt("currentTitleID")]);
        if (Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM cards WHERE cardTitle = ?', [prefs.getInt("currentTitleID")])) == 0) {
          lastQueryNum = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM cards WHERE cardTitle = ?', [prefs.getInt("currentTitleID")]));
          yield null;
        }
        yield await lastQuery;
      }
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
    return ((await db.rawQuery('SELECT * FROM titles WHERE titleID = ?', [prefs.getInt("currentTitleID")])) + (await db.rawQuery('SELECT * FROM cards WHERE cardTitle = ? ORDER BY position', [prefs.getInt("currentTitleID")])));
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
    for (int i = 0; i < oldTermCount!; i++) {
      time = DateTime
          .now()
          .millisecondsSinceEpoch;
      await db.rawQuery(
          'UPDATE cards SET timestamp = ?, term = ?, def = ? WHERE cardTitle = ? AND position = ?',
          [time, set.terms[i], set.defs[i], prefs.getInt('currentTitleID'), i]);
    }
    if (set.terms.length > oldTermCount) {
      for (int i = oldTermCount; i < set.terms.length; i++) {
        time = DateTime.now().millisecondsSinceEpoch;
        await db.rawQuery(
            'INSERT INTO cards(timestamp, position, term, def, correctInARow, cardTitle) VALUES(?, ?, ?, ?, ?, ?)',
            [time, i, set.terms[i], set.defs[i], 0, prefs.getInt('currentTitleID')]
        );
      }
    }
  }

  static Future<void> updateCorrectInARow(int position, int correctInARow) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    await db.rawQuery('UPDATE cards SET correctInARow = ? WHERE cardTitle = ? AND position = ?', [correctInARow, prefs.getInt('currentTitleID'), position]);
  }

  static Future<dynamic> getCorrectInARow(int position, int correctInARow) async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    return await db.rawQuery('SELECT correctInARow FROM cards WHERE cardTitle = ? AND position = ?', [prefs.getInt('currentTitleID'), position]);
  }

  static Future<void> deleteSet() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    // titles: (timestamp, position, title, desc, iconCP, iconFF, iconFP)
    //[time, set.position, set.title, set.desc, set.icon.codePoint, set.icon.fontFamily, set.icon.fontPackage]
    // cards(timestamp, position, term, def, correctInARow, cardTitle)
    // [time, i, set.terms[i], set.defs[i], 0, titleID]
    await db.rawQuery('DELETE FROM titles WHERE titleID = ?', [prefs.getInt('currentTitleID')]);
    await db.rawQuery('DELETE FROM cards WHERE cardTitle = ?', [prefs.getInt('currentTitleID')]);
  }

  static Future<void> debugDB() async {
    final db = await database;

    print(await db.rawQuery('SELECT * FROM titles'));
    print(await db.rawQuery('SELECT * FROM cards'));
  }

  static Future<void> clearTables() async {
    final db = await database;

    await db.rawQuery('DELETE FROM cards');
    await db.rawQuery('DELETE FROM titles');
    await db.rawQuery('VACUUM');
  }
}