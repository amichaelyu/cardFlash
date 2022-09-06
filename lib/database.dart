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
          'CREATE TABLE cards(cardID INTEGER PRIMARY KEY, timestamp INTEGER, position INTEGER, term TEXT, def TEXT, cardTitle INTEGER)', // , FOREIGN KEY(cardTitle) REFERENCES cards(titleID)
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
            'INSERT INTO cards(timestamp, position, term, def, cardTitle) VALUES(?, ?, ?, ?, ?)',
            [time, i, set.terms[i], set.defs[i], titleID]
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
      if (prefs.getInt("currentSet") != -1) {
        if (lastQuery == await db.rawQuery(
            'SELECT * FROM cards WHERE cardTitle = ? ORDER BY position', [prefs.getInt("currentSet")]) ||
            lastQueryNum == Sqflite.firstIntValue(
                await db.rawQuery('SELECT COUNT(*) FROM cards'))) continue;
        lastQuery =
        await db.rawQuery('SELECT * FROM cards WHERE cardTitle = ? ORDER BY position', [prefs.getInt("currentSet")]);
        if (Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM cards')) == 0) {
          lastQueryNum = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM cards'));
          yield null;
        }
        yield await lastQuery;
      }
    }
  }

  static Stream<dynamic> getData() async* {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();
    var lastQuery;
    var lastQueryNum;

    while (true) {
      if (prefs.getInt("currentSet") != -1) {
        if ((lastQuery == (await db.rawQuery('SELECT * FROM titles WHERE titleID = ?', [prefs.getInt("currentSet")]) + await db.rawQuery('SELECT * FROM cards WHERE cardTitle = ? ORDER BY position', [prefs.getInt("currentSet")]))) && (lastQueryNum != (Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cards WHERE cardTitle = ?', [prefs.getInt("currentSet")]))! + Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles where titleID = ?', [prefs.getInt("currentSet")]))!))) {
          continue;
        }
        lastQuery = ((await db.rawQuery('SELECT * FROM titles WHERE titleID = ?', [prefs.getInt("currentSet")])) + (await db.rawQuery('SELECT * FROM cards WHERE cardTitle = ? ORDER BY position', [prefs.getInt("currentSet")])));
        if ((Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cards WHERE cardTitle = ?', [prefs.getInt("currentSet")]))! + Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles WHERE titleID = ?', [prefs.getInt("currentSet")]))!) == 0) {lastQueryNum = (Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cards WHERE cardTitle = ?', [prefs.getInt("currentSet")]))! + Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM titles WHERE titleID = ?', [prefs.getInt("currentSet")]))!);
          yield null;
        }
        yield await lastQuery;
      }
    }
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