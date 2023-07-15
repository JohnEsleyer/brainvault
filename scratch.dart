import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:html' as html;

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
    db.execute('CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT)');
  });

  // Insert the users into the database
  for (var user in users) {
    await db.insert('users', user);
  }
}



void main() async {

  sqfliteFfiInit();


  var database = await databaseFactoryFfi.openDatabase('brain.db');

  final users = await database.query('users');

  for (var user in users){
    var id = user['id'];
    var name = user['name'];
    var email = user['email'];

    print('User: $id, $name');
  }
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

