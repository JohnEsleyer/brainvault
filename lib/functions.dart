

import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:js/js_util.dart' as jsUtil;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

bool isUrl(String input) {
  final regex = RegExp(
      r"^(?:http|https):\/\/(?:(?:[A-Z0-9][A-Z0-9_-]*)(?:\.[A-Z0-9][A-Z0-9_-]*)+)(?::\d{1,5})?(?:\/[^\s]*)?$",
      caseSensitive: false);
  return regex.hasMatch(input);
}

Future<void> downloadDatabase() async {
  var path = 'brain.db';
  var db = await openDatabase(path);

  // Query the data from the database
  final users = await db.query('users');

  // Convert the result to a JSON string
  final jsonData = json.encode(users);

  // Create a Blob with the JSON data
  final blob = html.Blob([jsonData], 'application/json');

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