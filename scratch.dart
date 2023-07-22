import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() async {
  databaseFactory = databaseFactoryFfi;
  // sqfliteFfiInit();

  // Open the database
  Database database = await openDatabase(
    'brain.db',
    version: 1,
    onCreate: (db, version) async {
      // Create the tables
      await db.execute('''
        CREATE TABLE Collection (
          ID INTEGER PRIMARY KEY,
          Name TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE Document (
          ID INTEGER PRIMARY KEY,
          Title TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE Note (
          ID INTEGER PRIMARY KEY,
          Content TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE DocumentTag (
          ID INTEGER PRIMARY KEY,
          DocumentID INTEGER,
          NameOfTag TEXT,
          CreatedAt TEXT,
          UpdatedAt TEXT,
          LastReviewedAt TEXT,
          NextReviewAt TEXT,
          ReviewInterval TEXT,
          OrderIndex INTEGER,
          FOREIGN KEY (DocumentID) REFERENCES Document (ID)
        )
      ''');

      await db.execute('''
        CREATE TABLE NoteTag (
          ID INTEGER PRIMARY KEY,
          NoteID INTEGER,
          Title TEXT,
          Content TEXT,
          CreatedAt TEXT,
          UpdatedAt TEXT,
          LastReviewedAt TEXT,
          NextReviewAt TEXT,
          ReviewInterval TEXT,
          OrderIndex INTEGER,
          FOREIGN KEY (NoteID) REFERENCES Note (ID)
        )
      ''');
    },
  );

  print('Database created successfully!');
}


// void main() async {
//   // All of your data is stored in boxes
//   Hive.init('Hive'); // Not needed in browser

//   var box = await Hive.openBox('testBox');
//   box.put('name', 'David');
//   print('Name: ${box.get('name')}');
// }


// Boxes are tables but does not have structure
// It can contain anything

// Boxes can also be encrypted

