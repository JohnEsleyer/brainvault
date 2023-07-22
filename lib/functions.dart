

import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';
import 'package:js/js_util.dart' as jsUtil;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

bool isUrl(String input) {
  final regex = RegExp(
      r"^(?:http|https):\/\/(?:(?:[A-Z0-9][A-Z0-9_-]*)(?:\.[A-Z0-9][A-Z0-9_-]*)+)(?::\d{1,5})?(?:\/[^\s]*)?$",
      caseSensitive: false);
  return regex.hasMatch(input);
}


Future<void> downloadDatabase() async {
  var path = 'brain3.db';

  // Fetch the .db file as an ArrayBuffer
  final request = await html.HttpRequest.request(path, responseType: 'arraybuffer');
  final arrayBuffer = request.response as ByteBuffer;

  // Convert the ArrayBuffer to Uint8List
  final uint8List = Uint8List.view(arrayBuffer);

  // Create a Blob from the Uint8List
  final blob = html.Blob([uint8List], 'application/octet-stream');

  // Create a download URL for the Blob
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Create a download link
  final anchor = html.AnchorElement()
    ..href = url
    ..download = 'brain.db';

  // Trigger the download
  anchor.click();

  // Cleanup
  html.Url.revokeObjectUrl(url);
}

Future<void> createBrain() async {
  // Create the database
  Database database = await openDatabase(
    'brain3.db',
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

  print('Brain created successfully!');
}


Future<void> uploadDatabase() async {
  final fileInput = html.FileUploadInputElement();
  fileInput.accept = '.db'; // Restrict file selection to .db files
  fileInput.click();

  await fileInput.onChange.first; // Wait for the user to select a file

  final file = fileInput.files!.first;
  final reader = html.FileReader();

  reader.readAsText(file);

  await reader.onLoad.first; // Wait for the file to be loaded

  final jsonData = reader.result as String;
  final users = json.decode(jsonData);

  var path = 'brain.db';
  var db = await openDatabase(path, version: 1, onCreate: (db, version) async {
    db.execute(
        'CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT)');
  });
  print('TABLE CREATED');

  // Insert users to the table
  for (var user in users){
    await db.insert('users', {'name': user['name'], 'email': user['email']});
  }


  // var temp = await db.query('users');

  // for (var user in temp) {
  //   print('User: ${user['name']}');
  // }
}